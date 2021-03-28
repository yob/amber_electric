#!/usr/bin/env ruby

require 'amber_electric'

puts AmberElectric::Prices.for(postcode: 3000).inspect
