# This file is a part of redmine_tags
# Redmine plugin, that adds tagging support.
#
# Copyright (c) 2010 Aleksey V Zapparov AKA ixti
#
# redmine_tags is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_tags is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_tags.  If not, see <http://www.gnu.org/licenses/>.

require 'redmine'

Redmine::Plugin.register :redmine_tags do
  name        'redmine_show_private_for_watcher'
  author      'NEXSTEP SOLUTIONS LLC'
  description 'Show private issues for watchers'
  version     '0.1'
  url         'https://github.com/NEXSTEP/redmine_show_private_for_watcher'
  author_url  'https://github.com/NEXSTEP'

  requires_redmine :version_or_higher => '2.1.0'

end


ActionDispatch::Callbacks.to_prepare do

  unless Issue.included_modules.include?(RedmineShowPrivateForWatcher::Patches::IssuePatch)
    Issue.send(:include, RedmineShowPrivateForWatcher::Patches::IssuePatch)
  end

end

