# From https://rubytutorial.io/actioncable-devise-authentication/

Warden::Manager.after_set_user do |user,auth,opts|
  scope = opts[:scope]
  auth.cookies.signed["#{scope}.id"] = user.id
  auth.cookies.signed["#{scope}.expires_at"] = 30.minutes.from_now
end

# Yes, this doesn't properly destroy the session for users who log out. There's
# a relatively short timeout on it, though, so hopefully this won't be a
# significant issue. Alternatively, we could add a database table for
# ActionCable sessions, but that doesn't seem worth it at this point.
Warden::Manager.before_logout do |user, auth, opts|
  scope = opts[:scope]
  auth.cookies.signed["#{scope}.id"] = nil
  auth.cookies.signed["#{scope}.expires_at"] = nil
end
