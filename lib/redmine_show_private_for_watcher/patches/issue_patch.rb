require_dependency 'issue'

module RedmineShowPrivateForWatcher
  module Patches
    module IssuePatch
      def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          class << self
            alias_method_chain :visible_condition, :watcher_fix
          end
          alias_method_chain :visible?, :watcher_fix
        end
      end

      module ClassMethods
        def visible_condition_with_watcher_fix(user, options={})
          Project.allowed_to_condition(user, :view_issues, options) do |role, user|
            # Keep the code DRY
            if [ 'default', 'own' ].include?(role.issues_visibility)
              user_ids = [user.id] + user.groups.map(&:id).compact
              watched_issues = Issue.watched_by(user).map(&:id)
              watched_issues_clause = watched_issues.empty? ? "" : " OR #{table_name}.id IN (#{watched_issues.join(',')})"
            end

            if user.logged?
              case role.issues_visibility
              when 'all'
                nil
              when 'default'
                "(#{table_name}.is_private = #{connection.quoted_false} OR #{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}) #{watched_issues_clause})"
              when 'own'
                "(#{table_name}.author_id = #{user.id} OR #{table_name}.assigned_to_id IN (#{user_ids.join(',')}) #{watched_issues_clause})"
              else
                '1=0'
              end
            else
              "(#{table_name}.is_private = #{connection.quoted_false})"
            end
          end
        end
      end

      module InstanceMethods

        def visible_with_watcher_fix?(usr=nil)
          (usr || User.current).allowed_to?(:view_issues, self.project) do |role, user|

            if user.logged?
              case role.issues_visibility
              when 'all'
                true
              when 'default'
                !self.is_private? || (self.author == user || user.is_or_belongs_to?(assigned_to) || self.watched_by?(user))
              when 'own'
                self.author == user || user.is_or_belongs_to?(assigned_to) || self.watched_by?(user)
              else
                false
              end
            else
              !self.is_private?
            end
          end
        end


      end

    end
  end
end

