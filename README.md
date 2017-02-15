# Authify::Web

## Introduction

Authify is a web service built from the ground up to simplify authentication and provide it securely to a collection of related web sites.

This is the web front-end for both using the service for UI-based applications and for configuring Authify itself. This means that this front-end displays the login screen that users of other applications will see when those applications are integrated with Authify, and this is the web front-end used to signup and manage Authify accounts, organizations, and more.

## The Details

So far, Authify::Web requires no persistence beyond a cookie in a user's browser.

## Installation

TODO

## Configuration

Authify::Web supports the following configuration settings, managed via environment variables of the same name:

* `AUTHIFY_PUBLIC_URL` - The full public URL used to access Authify::Web. This is in anticipation of front-end load-balancers, reverse-proxies, DNS CNAMEs, and other such trickery. This really should be set to however other machines can hit Authify::Web, but it defaults to `http://localhost:3000` for development.
* `AUTHIFY_API_URL` - The full URL of the Authify::API back-end. **HTTPS highly recommended**. Defaults to `http://localhost:9292` for development.
* `AUTHIFY_ACCESS_KEY` - The Trusted Delegate access key provided by the Authify::API. See the bottom of the "Details" section in the [Authify::API README](https://github.com/knuedge/authify-api#the-details) for information on creating this.
* `AUTHIFY_SECRET_KEY` - The Trusted Delegate secret key provided by the Authify::API.
* `AUTHIFY_JWT_ISSUER` - The issuer string used for creating JWTs. This **must** match the Authify::API side.
* `AUTHIFY_JWT_ALGORITHM` - The name of the [JWA](https://tools.ietf.org/html/draft-ietf-jose-json-web-algorithms-40) algorithm to use when verifying JWT signatures. Valid values are `ES256`, `ES384`, or `ES512`. Defaults to `ES512`. This **must** match the Authify::API side.
* `SECRET_KEY_BASE` - The secret key used by Rails to sign and verify cookies. This needs to be the same across **all** instances of Authify::Web (meaning all instances serving traffic for the same front-end URL). Make this something very long and as random as possible.
* `GITHUB_KEY` - Provide a GitHub key to enable the GitHub integration (for signing up and signing in via GitHub). See the [GitHub Applications Page](https://github.com/settings/applications) for more information. This is optional.
* `GITHUB_SECRET` - The GitHub secret used to complete the GitHub integration. Required only if `GITHUB_KEY` is provided.

### UI Customization

TODO

## Usage and Authentication Workflow

### Horrible Diagram

```plaintext
Authify                                   User                                         App
|                                          |                                             |
|                                          | ============== app/some/path ============>> |
|                                          |                                             |
|                                          | <<==== redirect authify/login?callback ==== |
|                                          |                                             |
| <<====== authify/login?callback ======== |                                             |
|                                          |                                             |
| ====== redirect app/callback?jwt =====>> |                                             |
|                                          |                                             |
|                                          | ============= app/callback?jwt ==========>> |
|                                          |                                             |
|                                          | <<======= redirect app/some/path ========== |
|                                          |                                             |
|                                          | ============== app/some/path ============>> |
```

### Integration Basics

To integrate with Authify::Web, an application needs:

* The `AUTHIFY_PUBLIC_URL` + `/login` to redirect users to for the login process to begin
* A callback URL capable of receiving and parsing a [JWT](https://en.wikipedia.org/wiki/JSON_Web_Token) via a `jwt` GET parameter, and the ability to Base64 encode this callback URL
* Either a means to dynamically retrieve the public key for Authify::API or access to a stored copy to verify a JWT signature
* A means to verify the issuer attribute of a JWT signature
* Optionally, a means of specifying the original URL a user requested (so users are seemlessly sent to their original destination after the login process is complete)

Let's review these in greater detail:

### A Simple Integration Example

Somewhere in an Authify-integrated application (i.e., _your_ application), there should be logic similar to the following for protected areas of the site:

```ruby
if current_user && current_user.logged_in?
  # Great, do your thing
else
  # Here, we're assuming Authify::Web is at https://auth.example.com/
  # and that this app is https://app.example.com
  callback_encoded = Base64.encode64('https://app.example.com/callback')
  auth_url         = 'https://auth.example.com/login?callback='
  full_auth_url    = auth_url + callback_encoded.chomp

  # Here, we make a session for the would-be user to come back to
  session[:before_login] = request.original_url

  # Now send the user to Authify::Web
  redirect_to full_auth_url
end
```

Note that in no way does integrating with Authify::Web require Ruby or the use of the above code. This is just an example to illustrate some pseudo-logic in an application that wants to integrate with Authify::Web.

From here, Authify takes over. The user will be presented with a login URL or the ability to signup (eventually, the ability to disable signups will be added). Once a user successfully completes the signin process on Authify::Web, the user will be redirected to the callback URL with a GET parameter added for `jwt=` and the JWT created for this signin. Note that Authify::Web will merge GET parameters, so the callback URL can contain its own GET parameters if desired.

In the above code example, the user would be redirected to `https://app.example.com/callback?jwt=1a30b...` at which point the integrated application takes back over. Here is some example code for the callback URL on an integrated application:

```ruby
def callback
  # Needs to be implemented in your favorite JWT library (IMPORTANT!)
  token = verify_token(params[:jwt])

  # Store the information passed from Authify about the user
  # in session.
  session[:user] = token['user']

  # Optionally check for other scopes, currently only `user_access` and
  # `admin_access` are possible. This will store whether the users is
  # considered an admin by Authify in session. Might not mean anything
  # to your application.
  session[:admin] = token['scopes'].include?('admin_access')

  # Grab the user's original destination
  next_path = session[:before_login]
  # Don't need this in session anymore
  session.delete(:before_login)

  # Send the user to their original destination if they had one
  redirect_to next_path ? next_path : root_path
end
```

Again, this is just example code. Implement it in any language or style suites the needs of the application.


### Verifying the JWT

The `verify_token` method is by far the most important part of this code. It **must** properly verify the JWT signature, the time at which the token was issued (`iat`), the issuer of the JWT (`iss`), the expiration time of the JWT (`exp`), and must be capable of extracting `scopes` and `user` from the token's payload. Ideally, this method would also verify that the `scopes` list includes `user_access` (meaning, in the context of Authify, that the token is valid for use by users).

To properly verify the JWT, the application needs to have the public key of the JWT issuer (in this case, the Authify::API). This can be downloaded programmatically as a PEM-encoded certificate via a call to the Authify::API on `/jwt/key` and parsing the JSON response, taking the data from the `data` key. It can also be retrieved directly by downloading the content from Authify::Web on `/about/jwt/download_key`, which just provides the raw PEM file content.

### The JWT Payload

At this point, the user is logged in and the integrated application knows some value things about them because of the JWT.

The JWT includes two components that may be useful to an application integrated with Authify: `user` and `scopes`.

The `user` structure from the token's payload includes something similar to this:

```javascript
{
  "username": "user@email.com",
  "uid": 192837,
  "organizations": [
    {
      "name": "exampleorg",
      "oid": 2838,
      "admin": false,
      "memberships": [
        {
          "name": "developers",
          "gid": 93948
        }
      ]
    },
    {
      "name": "otherorg",
      "oid": 9863,
      "admin": true,
      "memberships": []
    }
  ]
}
```

From this information, the integrated applications knows the user's email (`token['user']['username']`), the unique ID of the user in Authify (`token['user']['uid']`), and to which Authify organizations the user belongs. The "organizations" piece may not be of use to your applications, but it can be useful for determining group memberships and the user's role across tenancies.

The `scopes` structure is simply a list of scopes (or perhaps purposes) for which the JWT is valid. Currently, this will _always_ include `user_access`, but if the user is a global administrator for Authify, it will also include `admin_access`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/knuedge/authify-web.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

