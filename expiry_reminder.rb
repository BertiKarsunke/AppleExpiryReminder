require "spaceship"
require "io/console"
require "rest-client"
require "json"

TIME_NOW_UTC = Time.now.utc

def getAllCertificatesWithinExpiryPeriod(expiryPeriodDays)
  Spaceship::Portal.certificate.all.select { |certificate|
    certificateExpiryTime = certificate.expires.utc
    daysLeft = getDifferenceInDaysFromNow(certificateExpiryTime)
    !(certificate.is_a? Spaceship::Portal.certificate.development) and daysLeft <= expiryPeriodDays  
  }
end

def getAllProfilesWithinExpiryPeriod(expiryPeriodDays)
  Spaceship::Portal.provisioning_profile.all.select { |profile|
    # Convert DateTime object to Time object
    profileExpiryTime = Time.parse(profile.expires.to_s).utc
    daysLeft = getDifferenceInDaysFromNow(profileExpiryTime)
    profile.status.downcase != "invalid" and daysLeft <= expiryPeriodDays
  }
end

def getDifferenceInDaysFromNow(time)
  ((time - TIME_NOW_UTC)/(24 * 3600)).round
end

def displayExpiringCertificateDetails(certificates)
  puts "Displaying Certificates - "
  certificates.each do |certificate|
    puts certificate
  end
end

def displayExpiringProfileDetails(profiles)
  puts "Displaying Profiles - "
  profiles.each do |profile|
    profileDetail = %Q(
    name - #{profile.name}
    expires - #{profile.expires}
    status - #{profile.status}
    AppName - #{profile.app.name}
    BundleID - #{profile.app.bundle_id}
    )
    puts profileDetail
  end
end

def formattedTitle(message)
  "<strong>#{message}</strong>"
end

def getFormattedCertificateString(certificate)
  [
    "#{formattedTitle("Id")} - #{certificate.id}",
    "#{formattedTitle("Name")} - #{certificate.name}",
    "#{formattedTitle("Expires")} - #{certificate.expires.utc.strftime("%d of %B, %Y")}",
    "#{formattedTitle("Owner_name")} - #{certificate.owner_name}"
  ].join("<br/>") + "<br/>"
end

def getFormattedCertificates(certificates)
  certificates.map { |certificate| getFormattedCertificateString(certificate) }.join("<br/>")
end

def getFormattedProfileString(profile)
  [
    "#{formattedTitle("Name")} - #{profile.name}",
    "#{formattedTitle("Expires")} - #{Time.parse(profile.expires.to_s).utc.strftime("%d of %B, %Y")}",
    "#{formattedTitle("Status")} - #{profile.status}",
    "#{formattedTitle("App Name")} - #{profile.app.name}",
    "#{formattedTitle("Bundle ID")} - #{profile.app.bundle_id}"
  ].join("<br/>") + "<br/>"
end

def getFormattedProfiles(profiles)
  profiles.map { |profile| getFormattedProfileString(profile) }.join("<br/>")
end

def getFlockMLBody(certificates, profiles, expiryPeriodDays)
  [
    "<flockml>",
    [
      "<u>#{formattedTitle("Reminder")}</u><br/>",
      (certificates.empty?) ? formattedTitle("No certificates expiring within #{expiryPeriodDays} days :)") : "#{formattedTitle("Certificates Expiring within #{expiryPeriodDays} days:")}<br/>",
      (certificates.empty?) ? "" : "#{getFormattedCertificates(certificates)}<br/>",
      (profiles.empty?) ? formattedTitle("No profiles expiring within #{expiryPeriodDays} days :)"): "#{formattedTitle("Profiles Expiring within #{expiryPeriodDays} days:")}<br/>",
      (profiles.empty?) ? "" : "#{getFormattedProfiles(profiles)}<br/>"
    ].join("<br/>"),
    "</flockml>"
  ].join("")
end


def sendDetails(certificates, profiles, expiryPeriodDays)
  headers = {
    "Content-Type" => "application/json"
  }
  puts "Reminder"
  puts certificates

  # puts(getFlockMLBody(certificates,profiles,expiryPeriodDays))
  # request_body = {
  #  flockml: getFlockMLBody(certificates, profiles, expiryPeriodDays)  
  # }
  # RestClient.post(endpoint, request_body.to_json, headers)
end

def login(username, password, teamId)
  Spaceship::Portal.login(username, password)
  Spaceship::Portal.client.team_id = teamId
end

def main()
  username = ARGV[0]
  password = ARGV[1]
  # flockChannelWebhookURL = ARGV[2]
  teamID = ARGV[2]
  expiryPeriodDays = ARGV[3].to_i

  login(username, password, teamID)

  expiringCertificates = getAllCertificatesWithinExpiryPeriod(expiryPeriodDays)
  expiringProfiles = getAllProfilesWithinExpiryPeriod(expiryPeriodDays)
  
  displayExpiringCertificateDetails(expiringCertificates)
  displayExpiringProfileDetails(expiringProfiles)

  sendDetails(expiringCertificates, expiringProfiles, expiryPeriodDays)
end

if __FILE__ == $0
  main()
end
