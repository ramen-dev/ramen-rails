# ramen-rails
[![Build Status](https://travis-ci.org/ramen-dev/ramen-rails.svg)](https://travis-ci.org/ramen-dev/ramen-rails)

This is a Rails helper for [Ramen](https://ramen.is). Ramen is a product that helps
B2B SaaS product managers build better products by giving them tools to better understand
what their customers need, and how satisfied their customers are with the results.

This gem will automatically inject the `ramen.js` script tag into pages.

# Installation
Add this to your Gemfile:

```
gem "ramen-rails", "~> 0.6.0"
```

Then run:

```
bundle install
```

# Usage

The following command will add `ramen.rb` to your `config/initializers`.
You can get your ID and SECRET in your Ramen Management Console.

```
rails g ramen:config ORGANIZATION_ID ORGANIZATION_SECRET
```

# Configuration

There is now a file in your application at `config/initializers/ramen.rb`.

Here is an overview of the major configuration options.

Option | Type | Required | Description
--- | --- | --- | ---
`organization_id`     | String  | Yes | Unique ID for your Organization
`organization_secret` | String  | No  | Enables Secure Mode
`current_user`        | Proc    | No  | Returns a Ruby object that responds to methods in the Customer Spec. Falls back to trying `current_user`, then `@user`
`current_company`     | Proc    | No  | Returns a Ruby object that responds to methods in the Company Spec. Falls back to trying `current_company`, then `@company`
`custom_links`        | Array   | No  | A Ruby array of hashes that have attributes from the Custom Links Spec.


Documentation for Customers, Companies, Traits, Custom Links, and more, can be found at [Ramen Developer Docs](http://docs.ramen.is).

---

# A note on `Proc` vs. `-> {}`
When assigning values in `ramen.rb`, use `Proc.new { ... }` and not `-> { ... }`.
There are some inconsistencies between Ruby versions with how arity is
handled on `Proc` vs. `-> {}`, and if you use the latter, you will get
confusing errors when you boot up your application.

---

# Manually setting ramenSettings
The Rubygem will add two script tags to the bottom of your `<body>` tag.
There may be instances where you want to set properties on `ramenSettings` directly in
JavaScript.
For this reason, the gem does not simply assign a new object as follows:

```
<script>window.ramenSettings = {...};</script>
```

Instead, the gem injects JavaScript that will do a shallow merge with `ramenSettings` if it already
exists. You can see an example of this
[here](https://github.com/ramen-dev/ramen-rails/blob/dbefcf336873e936b1f71128a63344d479802470/lib/ramen-rails/script_tag.rb#L37)

This way, you can set options like `ramenSettings.custom_links` in a template manually based on who is logged
in, for example.

---


# Thanks
This gem was heavily inspired by the [intercom-rails](https://github.com/intercom/intercom-rails)
gem. We <3 Intercom at Ramen. If you're looking for a nice way to have conversations
with your customers in your web application, give them a holler.


# License
MIT-LICENSE for life.
