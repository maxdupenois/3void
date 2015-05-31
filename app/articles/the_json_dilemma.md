$title: The JSON Dilemma
$author: Max
$tags: rails, api, technical, json
$published: true
$last_updated_at: 2014-05-31 11:57:49

## JSON Parsing in rails

Part of one of the apps I've been working on has to deal with what are
sometimes large JSON responses with nested objects and arrays. 
I noticed that a large chunk of the request time was spent just parsing 
the JSON into ruby hashes and decided to do a little bit of digging 
to see if we could speed it up.

First we create some test hashes which are similar to those that the
app processes.

~~~ruby
keys = ('a'..'z').map(&:to_sym)
values = ["hello", 2.33, 1000, "there", :something]

make_hsh = lambda do |keys, values|
  keys.reduce({}) do |hsh, key|
    hsh[key] = values.shuffle.first
    hsh
  end
end

array_of_hashes = (0...5000).map do 
  hsh = make_hsh.call(keys, values)
  hsh[:internal_hash] = make_hsh.call(keys, values)
  hsh
end
~~~

When rails processes a JSON string from an external API it uses MultiJson
and I believe the default adapter it uses is YAJL (Yet Another JSON 
Library, <a href="http://lloyd.github.io/yajl/">http://lloyd.github.io/yajl/</a>).

~~~ruby
require 'active_support'
require 'yajl'
puts ActiveSupport::JSON.backend #=> MultiJson::Adapters::Yajl
~~~

Then I checked the speed of parsing the array of test hashes for MultiJson
loaded Yajl and the default ruby JSON parser.

~~~ruby
require 'benchmark'
require 'json'
Benchmark.bm(22) do |x|
  x.report('ActiveSupport with YAJL'){ ActiveSupport::JSON.encode(array_of_hashes)}
  x.report('Base JSON Encoder'){ ::JSON.generate(array_of_hashes)}
end
~~~

~~~
                             user     system      total        real
 ActiveSupport with YAJL  3.550000   0.030000   3.580000 (  3.579521)
 Base JSON Encoder        0.810000   0.020000   0.830000 (  0.826839)
~~~

... Wat? That difference is pretty marked and is slightly confusing as
YAJL is a C library and should be blindingly fast. I'm not sure why it's so
much slower but I suspect it's something to do with MultiJSON, when I do 
find out, I'll ad an addendum to this article with the information.
