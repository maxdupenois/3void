$title: The JSON Dilemma
$author: Max
$tags: rails, api, technical, json
$published: true

## JSON Parsing in rails

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


~~~ruby
require 'active_support'
require 'yajl'
puts ActiveSupport::JSON.backend #=> MultiJson::Adapters::Yajl
~~~


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
