require 'open-uri'
require 'json'
require 'optparse'

class Profile
  attr_reader :email, :name, :job_info, :success, :memberships

  def initialize person
    if person
      @email = person['email']
      @name = person['name']
      @success = person['success']
      @job_info = []
      @memberships = []

      person['occupations'].each do |occupation|
        @job_info << [occupation['job_title'], occupation['company']]
      end

      person['memberships'].each do |membership|
        @memberships << [membership['site_name'], membership['profile_url']]
      end
    end
  end

  def inspect
    puts ''
    puts self.email
    puts "Name: #{self.name}"

    self.job_info.each do |job|
      puts "Position: #{job[0]}"
      puts "Company: #{job[1]}"
    end

    self.memberships.each do |membership|
      puts "#{membership[0]} - #{membership[1]}"
    end
  end
end

# Email permutations from
# first_name, # middle_name, last_name, domain
def permutate fn, ln, domain

  fi = fn[0]
  li = ln[0]
  # mi = mn[0]

  # name combinations
  fi_perms = [fi].product ['',
                           '_' + li,
                           '_' + ln,
                           '-' + li,
                           '-' + ln,
                           '.' + li,
                           '.' + ln,
                           li,
                           ln]
  # mi + '_' + ln,
  # mi + '-' + ln,
  # mi + '.' + ln,
  # mi + ln]
  fn_perms = [fn].product ['',
                           '_' + li,
                           '_' + ln,
                           # '_' + mi + '_' + ln,
                           # '_' + mn + '_' + ln,
                           '-' + li,
                           '-' + ln,
                           # '-' + mi + '-' + ln,
                           # '-' + mn + '-' + ln,
                           '.' + li,
                           '.' + ln,
                           # '.' + mi + '.' + ln,
                           # '.' + mn + '.' + ln,
                           li,
                           ln ]
  # mi + ln,
  # mn + ln
  li_perms = [li].product ['',
                           '_' + fi,
                           '_' + fn,
                           '-' + fi,
                           '-' + fn,
                           '.' + fi,
                           '.' + fn,
                           fi,
                           fn]
  ln_perms = [ln].product ['',
                           '_' + fi,
                           '_' + fn,
                           '-' + fi,
                           '-' + fn,
                           '.' + fi,
                           '.' + fn,
                           fi,
                           fn]

  # combine into one array
  raw_perms = fn_perms + ln_perms+ fi_perms + li_perms

  name_perms = []

  # [[fn, '_' + li]] => [[fn + '_' + li]]
  raw_perms.each do |perm|
    name_perms << perm.join
  end

  # accept domain arg to be a string or an array
  # %40 => @
  if domain.is_a? String
    domain = ['%40'].product domain.split
  elsif domain.is_a? Array
    domain = ['%40'].product domain
  else
    raise ArgumentError, 'Domain was neither a String or Array'
  end

  name_and_domains = name_perms.product domain

  # combine names and domains
  permutations = name_and_domains.map {|email| email.join }

  permutations
end

# Find info about each generated email
def find_valid_email emails
  emails.each do |email|
    process_email email
  end
end

# Sends a query to the undocumented Rapportive API
# return hash object
def request email
  status_url = 'https://rapportive.com/login_status?user_email=' + email

  # exponential backoff
  tries = 0
  begin
    tries += 1
    response = JSON.parse(open(status_url).read)
    session_token = response['session_token']
  rescue OpenURI::HTTPError => e
    if tries < 2
      sleep(2**tries)
      retry
    else
      return e
    end
  end

  if response['error']
    false
  elsif response['status'] == 200 && session_token
    profile_url = 'https://profiles.rapportive.com/contacts/email/' + email

    header = { 'X-Session-Token' => session_token }
    response = JSON.parse(open(profile_url, header).read)

    if response['success'] != 'nothing_useful'
      Profile.new(response['contact'])
    end
  end
end

# Find email address in rapportive
def process_email email
  profile = request email

  begin
    profile.success
  rescue NoMethodError
    return print '.'
  end

  if profile && profile.success != 'nothing_useful'
    profile.inspect
  else
    print '.'
  end
end

def find_email fn, ln, domain
  permutations = permutate fn, ln, domain
  find_valid_email permutations
end

# putting it all together
def main

  options = {}
  OptionParser.new do |opts|

    opts.on('--domains domain1, domain2, domain3', Array, 'Use multiple domains') do |d|
      options[:domains] = d
    end

    opts.on('-e', '--email email', Array, 'Search for a single email') do |e|
      options[:email] = e
    end
  end.parse!

  # given a single email or a names and domains
  if options[:email]
    find_valid_email options[:email]
    # list of domains
  elsif options[:domains]
    find_email ARGV[0], ARGV[1], options[:domains]
    # single domain
  else
    find_email ARGV[0], ARGV[1], ARGV[2]
  end
end

main
