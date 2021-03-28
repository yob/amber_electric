# Amber Electric

A ruby API client for https://amberelectric.com.au, an Australian electricity retailer.

Currently Amber only provides an unauthenticated API for pricing, so no credentials are required.

## Installation

    gem install amber_electric

... or add it to your Gemfile:

    gem "amber_electric"

## Usage

    require "amber_electric"
    
    puts AmberElectric::Prices.for(postcode: 3000).inspect
