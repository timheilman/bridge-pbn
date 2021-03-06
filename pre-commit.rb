#!/usr/bin/env ruby

require 'english'
require 'rubocop'

ADDED_OR_MODIFIED = /A|AM|^M/

# to prevent code injection: system is a dangerous call
def raise_single_quote_error
  raise ArgumentError, 'Single quotes are not allowed in filenames here.'
end

def extract_file_name(file_name_with_status)
  file_name_array = file_name_with_status.strip.split(' ')
  file_name_array.shift
  fname = file_name_array.join(' ')
  fname[0] = '' if fname[0] == '"'
  fname[fname.length - 1] = '' if fname[fname.length - 1] == '"'
  raise_single_quote_error if fname.include?("'")
  fname
end

changed_files =
  `git status --porcelain`
  .split(/\n/)
  .select { |file_name_with_status| file_name_with_status =~ ADDED_OR_MODIFIED }
  .map { |file_name_with_status| extract_file_name file_name_with_status }
  .select { |file_name| File.extname(file_name) =~ /.rb/ }
  .join("' '")

system("rubocop '#{changed_files}'") unless changed_files.empty?

exit $CHILD_STATUS.to_s[-1].to_i
