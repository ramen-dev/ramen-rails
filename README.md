# ramen-rails
[![Build Status](https://travis-ci.org/ramen-dev/ramen-rails.svg)](https://travis-ci.org/ramen-dev/ramen-rails)

This is a Rails helper for [Ramen](https://ramen.is). Ramen is a product that helps
B2B SaaS product managers build better products by giving them tools to better understand
what their customers need, and how satisfied their customers are with the results.

This gem will automatically inject the `ramen.js` script tag into pages.

# Installation
Add this to your Gemfile:

```
gem "ramen-rails"
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

# Thanks
This gem was heavily inspired by the [intercom-rails](https://github.com/intercom/intercom-rails)
gem. We <3 Intercom at Ramen. If you're looking for a nice way to have conversations
with your customers in your web application, give them a holler.


# License
MIT-LICENSE for life.
