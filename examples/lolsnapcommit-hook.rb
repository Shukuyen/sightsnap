#!/usr/bin/env ruby

# to install simply copy to somewhere in your path where this script will stay
# and either make sure sightsnap is in your path e.g. /usr/bin or you supply the
# full path here instead of the shorthand
sightsnap = "sightsnap"

# then run     lolsnapcommit-hook.rb --install  to install the hook in a repository when inside the repo
# you can run  lolsnapcommit-hook.rb   to test it for the most recent commit
# or run       lolsnapcommit-hook.rb --remove   to remove the hook again
# or run       lolsnapcommit-hook.rb --show     to show the lolsnap-directory

# git parameters to use
commit = %x[git rev-parse --verify HEAD].strip
short_commit = commit[0..12]
top_level_dir = %x[git rev-parse --show-toplevel].strip
repo_name = File.basename(top_level_dir)
revision_number = %x[git rev-list HEAD | wc -l;].strip
commit_message = %x[git log -n 1 HEAD --format=format:%s%n%b].strip
branch_name = %x[git rev-parse --abbrev-ref HEAD].strip

base_snap_path =  File.expand_path "~/Library/Application Support/lolsnap/"

# install and remove
commit_hook_path = File.join(top_level_dir, '.git/hooks/post-commit')
ARGV.each {|arg|
	if (arg == "--install") then
		here = File.expand_path(__FILE__)
		%x[echo '#!/bin/sh\n#{here}' > '#{commit_hook_path}' && chmod a+x '#{commit_hook_path}']
		print "installed lolsnap post-commit hook\n"
		exit (0)
	elsif (arg == "--remove") then 
		%x[mv '#{commit_hook_path}' '#{commit_hook_path}.lolsnap.old']
		print "removed lolsnap post-commit hook\n"
		exit (0)
	elsif (arg == "--show") then 
		%x[open '#{base_snap_path}']
		exit(0)
	end
}


# single character escaping
class String
    def escape_single
        self.gsub("'","'\\\\''")
    end
end


# settings
title = "%s %s:%10s" % [repo_name, branch_name, short_commit]
font = "Impact"
#font = "Futura-CondensedMedium"
font_size = 40

#print title, "\n"
#print commit_message, "\n"

snap_path = File.join(base_snap_path,"#{repo_name}/#{repo_name}_#{short_commit}.jpg")

%x[#{sightsnap} -p -T='#{title.escape_single}' -C='#{commit_message.escape_single}' -j 0.6 -f '#{font}' -s '#{font_size}' '#{snap_path.escape_single}' && open '#{snap_path.escape_single}']