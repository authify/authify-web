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

TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/knuedge/authify-web.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

