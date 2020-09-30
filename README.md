# Expiry Reminder Script
Summary - A simple script to all the certificates and profiles on Apple Developer Portal which are going to expiry within the given number of days.

### Why do we need this?
- Apple developers have their certificates and profiles on the developer portal.
- Different profiles and certificates have different expiry periods.
- Although Apple does send email notification 30 days before expiry, but we all agree that emails suck!! :innocent:
- Also as an organisation, if one has a large number of developer certificates and profiles, this could be a blessing.

### What does this script do?
- Fetch all the certificates and profiles and filter them according to the condition - if they are within the expiry period.
- Generate a message and notify the users on Flock Channel. (Get Flocking here: - www.flock.com)

## Usage
```BASH
ruby expiry_reminder.rb ${USERNAME} ${PASSWORD} ${FLOCK_CHANNEL_WEBHOOK_URL} ${TEAM_ID} ${EXPIRY_PERIOD}
```
Where:
- USERNAME, PASSWORD - Apple dev portal username and password.
- FLOCK_CHANNEL_WEBHOOK_URL - We can create a incoming webhook for a flock channel and send messages to the channel using it.
- EXPIRY_PERIOD - Number of days to expiry. Those certificates and profiles will be fetched which will be expiring within this period.

Example: 
```BASH
ruby expiry_reminder.rb foo bar url IDxxxxx 30
```
Fetch all those certificates and profiles which are going to expire within 30 days from now.

One can setup a cron job to run the script every day.