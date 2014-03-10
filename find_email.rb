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
# first_name, last_name, domain
def permutate(first_name, last_name, domain)

  first_initial = first_name[0]
  last_initial = last_name[0]

  # Define each name permutation manually
  name_permutations = <<PERMS
{first_name}
{last_name}
{first_initial}
{last_initial}
{first_name}{last_name}
{first_name}.{last_name}
{first_initial}{last_name}
{first_initial}.{last_name}
{first_name}{last_initial}
{first_name}.{last_initial}
{first_initial}{last_initial}
{first_initial}.{last_initial}
{last_name}{first_name}
{last_name}.{first_name}
{last_name}{first_initial}
{last_name}.{first_initial}
{last_initial}{first_name}
{last_initial}.{first_name}
{last_initial}{first_initial}
{last_initial}.{first_initial}
{first_name}-{last_name}
{first_initial}-{last_name}
{first_name}-{last_initial}
{first_initial}-{last_initial}
{last_name}-{first_name}
{last_name}-{first_initial}
{last_initial}-{first_name}
{last_initial}-{first_initial}
{first_name}_{last_name}
{first_initial}_{last_name}
{first_name}_{last_initial}
{first_initial}_{last_initial}
{last_name}_{first_name}
{last_name}_{first_initial}
{last_initial}_{first_name}
{last_initial}_{first_initial}
PERMS

  # substitutions to get all permutations to an Array
  name_permutations = name_permutations.gsub('{first_name}', first_name)
                                       .gsub('{last_name}', last_name)
                                       .gsub('{first_initial}', first_initial)
                                       .gsub('{last_initial}', last_initial)
                                       .split($/)

  # accept domain arg to be a string or an array
  # %40 => @
  if domain.is_a? String
    domain = ['%40'].product domain.split
  elsif domain.is_a? Array
    domain = ['%40'].product domain
  else
    raise ArgumentError, 'Domain was neither a String or Array'
  end

  name_and_domains = name_permutations.product domain

  # combine names and domains
  # return permuations
  permutations = name_and_domains.map {|email| email.join }
end

# Find info about each generated email
def find_valid_email(emails)
  emails.each do |email|
    process_email email
  end
end

# Sends a query to the undocumented Rapportive API
# return Profile object if valid email
def request(email)
  status_url = 'https://rapportive.com/login_status?user_email=' + email
  profile_url = 'https://profiles.rapportive.com/contacts/email/' + email

  # exponential backoff to get session_token
  response = exp_backoff 2, status_url
  session_token = response['session_token'] if response

  if response.nil? || response['error']
    false
  elsif response['status'] == 200 && session_token
    header = { 'X-Session-Token' => session_token }

    # Create a Profile for valid email
    response = exp_backoff 2, profile_url, header
    if response.nil?
      false
    elsif response['success'] != 'nothing_useful'
      Profile.new(response['contact'])
    end
  end
end

# Exponential Backoff when visiting a URL
def exp_backoff(up_to, url, header = {})
  tries = 0
  begin
    tries += 1
    response = JSON.parse(open(url, header).read)
  rescue OpenURI::HTTPError
    if tries < up_to
      sleep( 2 ** tries )
      retry
    end
  end
end

# Find email address in rapportive
def process_email(email)
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

def find_email(fn, ln, domain)
  permutations = permutate fn, ln, domain
  find_valid_email permutations
end

# putting it all together with options
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
