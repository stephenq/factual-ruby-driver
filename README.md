# About

This is the Factual-supported Ruby driver for [Factual's public API](http://developer.factual.com).

# Install

```bash
$ gem install factual-api
```

# Get Started

Include this driver in your project:
```ruby
require 'factual'
factual = Factual.new("YOUR_KEY", "YOUR_SECRET")
```
If you don't have a Factual API key yet, [it's free and easy to get one](https://www.factual.com/api-keys/request).

## Schema
Use the schema API call to determine which fields are available, the datatypes of those fields, and which operations (sorting, searching, writing, facetting) can be performed on each field.

Full documentation: http://developer.factual.com/api-docs/#Schema
```ruby
factual.table("places-us").schema
```

## Read
Use the read API call to query data in Factual tables with any combination of full-text search, parametric filtering, and geo-location filtering.

Full documentation: http://developer.factual.com/api-docs/#Read

Related place-specific documentation:
* Categories: http://developer.factual.com/working-with-categories/
* Placerank, Sorting: http://developer.factual.com/search-placerank-and-boost/

```ruby


# Full-text search:
factual.table("places-us").search("century city mall").rows

# Row filters:
#  search restaurants (http://developer.factual.com/working-with-categories/)
#  note that this will return all sub-categories of 347 as well.
factual.table("places-us").filters("category_ids" => {"$includes" => 347}).rows

#  search restaurants or bars
factual.table("places-us").filters("category_ids" => {"$includes_any" => [312, 347]}).rows

#  search entertainment venues but NOT adult entertainment
factual.table("places-us").filters("$and" => [{"category_ids" => {"$includes" => 317}}, {"category_ids" => {"$excludes" => 318}}]).rows

#  search for Starbucks in Los Angeles
factual.table("places-us").search("starbucks").filters("locality" => "los angeles").rows

#  search for starbucks in Los Angeles or Santa Monica 
factual.table("places-us").search("starbucks").filters("$or" => [{"locality" => {"$eq" =>"los angeles"}}, {"locality" => {"$eq" => "santa monica"}}]).rows

# Paging:
#  search for starbucks in Los Angeles or Santa Monica (second page of results):
factual.table("places-us").search("starbucks").filters("$or" => [{"locality" => {"$eq" =>"los angeles"}}, {"locality" => {"$eq" => "santa monica"}}]).page(2, :per => 20).rows

# Geo filter:
#  coffee near the Factual office
factual.table("places-us").search("coffee").geo("$circle" => {"$center" => [34.058583, -118.416582], "$meters" => 1000}).rows

# Existence threshold:
#  prefer precision over recall:
factual.table("places-us").threshold("confident").rows

# Get a row by factual id:
factual.table("places-us").row("03c26917-5d66-4de9-96bc-b13066173c65")

```

## Facets
Use the facets call to get summarized counts, grouped by specified fields.

Full documentation: http://developer.factual.com/api-docs/#Facets
```ruby
# show top 5 cities that have more than 20 Starbucks in California
factual.facets("places-us").select("locality").search("starbucks").filters("region" => "CA").min_count(20).limit(5).columns
```

## Resolve
Use resolve to generate a confidence-based match to an existing set of place attributes.

Full documentation: http://developer.factual.com/api-docs/#Resolve
```ruby
# resovle from name and address info
factual.resolve("places-us").values("name" => "McDonalds", "address" => "10451 Santa Monica Blvd", "region" => "CA", "postcode" => "90025").rows

# resolve from name and geo location
factual.match("places-us").values("name" => "McDonalds", "latitude" => 34.05671, "longitude" => -118.42586).rows
```

## Match
Match is similar to resolve, but returns only the Factual ID and is intended for high volume mapping.

Full documentation: http://developer.factual.com/api-docs/#Match
```ruby
factual.table("places-us").match("name" => "McDonalds", "address" => "10451 Santa Monica Blvd", "region" => "CA", "postcode" => "90025").rows
```

## Crosswalk
Crosswalk contains third party mappings between entities.

Full documentation: http://developer.factual.com/places-crosswalk/

```ruby
# Query with factual id, and only show entites from Yelp:
factual.table("crosswalk").filters("factual_id" => "3b9e2b46-4961-4a31-b90a-b5e0aed2a45e", "namespace" => "yelp").rows
```

```ruby
# query with an entity from Foursquare:
factual.table("crosswalk").filters("namespace" => "foursquare", "namespace_id" => "4ae4df6df964a520019f21e3").rows
```

## World Geographies
World Geographies contains administrative geographies (states, counties, countries), natural geographies (rivers, oceans, continents), and assorted geographic miscallaney.  This resource is intended to complement the Global Places and add utility to any geo-related content.

```ruby
# find California, USA
factual.table("world-geographies").select("contextname", "factual_id").search("los angeles").filters("name" => "California", "country" => "US", "placetype" => "region").rows
# returns 08649c86-8f76-11e1-848f-cfd5bf3ef515 as the Factual Id of "California, US"
```

```ruby
# find cities and town in California (first 20 rows)
factual.table("world-geographies").select("contextname", "factual_id").search("los angeles").filters("ancestors" => {"$includes" => "08649c86-8f76-11e1-848f-cfd5bf3ef515"}, "country" => "US", "placetype" => "locality").rows
```

## Submit
Submit new data, or update existing data. Submit behaves as an "upsert", meaning that Factual will attempt to match the provided data against any existing places first. Note: you should ALWAYS store the *commit ID* returned from the response for any future support requests.

Full documentation: http://developer.factual.com/api-docs/#Submit

Place-specific Write API documentation: http://developer.factual.com/write-api/

```ruby
new_value = {
  name: "Factual",
  address: "1999 Avenue of the Stars",
  address_extended: "34th floor",
  locality: "Los Angeles",
  region: "CA",
  postcode: "90067",
  country: "us",
  latitude: 34.058743,
  longitude: -118.41694,
  category_ids: [209,213],
  hours: "Mon 11:30am-2pm Tue-Fri 11:30am-2pm, 5:30pm-9pm Sat-Sun closed"
}
factual.submit("us-sandbox", "a_user_id").values(new_value).write
```

Edit an existing row:
```ruby
factual.submit("us-sandbox", "a_user_id", "4e4a14fe-988c-4f03-a8e7-0efc806d0a7f").values(address_extended: "35th floor").write
```


## Flag
Use the flag API to flag problems in existing data.

Full documentation: http://developer.factual.com/api-docs/#Flag

Flag a place that is a duplicate of another. The *preferred* entity that should persist is passed as a GET parameter.
```ruby
factual.flag("us-sandbox", "a_user_id", "4e4a14fe-988c-4f03-a8e7-0efc806d0a7f", :duplicate).preferred("9d676355-6c74-4cf6-8c4a-03fdaaa2d66a").write
```

Flag a place that is closed.
```ruby
factual.flag("us-sandbox", "a_user_id", "4e4a14fe-988c-4f03-a8e7-0efc806d0a7f", :closed).comment("was shut down when I went there yesterday.").write
```

Flag a place that has been relocated, so that it will redirect to the new location. The *preferred* entity (the current location) is passed as a GET parameter. The old location is identified in the URL.
```ruby
factual.flag("us-sandbox", "a_user_id", "4e4a14fe-988c-4f03-a8e7-0efc806d0a7f", :relocated).preferred("9d676355-6c74-4cf6-8c4a-03fdaaa2d66a").write
```

## Clear
The clear API is used to signal that an existing attribute's value should be reset.

Full documentation: http://developer.factual.com/api-docs/#Clear
```ruby
factual.clear("us-sandbox", "a_user_id", "4e4a14fe-988c-4f03-a8e7-0efc806d0a7f").fields(:latitude, :longitude).write
```

## Boost
The boost API is used to signal rows that should appear higher in search results.

Full documentation: http://developer.factual.com/api-docs/#Boost
```ruby
factual.boost("us-sandbox", "a_user_id", "4e4a14fe-988c-4f03-a8e7-0efc806d0a7f", "local business data").write
```

## Multi
Make up to three simultaneous requests over a single HTTP connection. Note: while the requests are performed in parallel, the final response is not returned until all contained requests are complete. As such, you shouldn't use multi if you want non-blocking behavior. Also note that a contained response may include an API error message, if appropriate.

Full documentation: http://developer.factual.com/api-docs/#Multi

```ruby
# Query read and facets in one request:
read_query = factual.table("places-us").search("starbucks").geo("$circle" => {"$center" => [34.041195, -118.331518], "$meters" => 1000})
facets_query = factual.facets("places-us").search("starbucks").filters("region" => "CA").select("locality").min_count(20).limit(5)
factual.multi(read: read_query, facets: facets_query)
```


## Error Handling
The errors are thrown as StandardError instances.

## Debug Mode
To see detailed debug information at runtime, you can turn on Debug Mode:
```ruby
# start debug mode
factual = Factual.new(key, secret, :debug => true)

# run your querie(s)

```
Debug Mode will output useful information about what's going on, including  the request sent to Factual and the response from Factual, outputting to stdout and stderr.


## Custom timeouts
You can set the request timeout (in seconds):
```ruby
# set the timeout as 1 second
factual = Factual.new(key, secret, :timeout => 1)

```
You will get [Timeout::Error: execution expired] for custom timeout errors.


# Where to Get Help

If you think you've identified a specific bug in this driver, please file an issue in the github repo. Please be as specific as you can, including:

  * What you did to surface the bug
  * What you expected to happen
  * What actually happened
  * Detailed stack trace and/or line numbers

If you are having any other kind of issue, such as unexpected data or strange behaviour from Factual's API (or you're just not sure WHAT'S going on), please contact us through the [Factual support site](http://support.factual.com/factual).
