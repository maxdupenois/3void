$title: The JSON Dilemma
$author: Max
$tags: rails, api, technical, json
$published: true

## JSON Parsing in rails

~~~ruby
keys = (a..z).map(&:to_sym)
values = ["hello", 02.33, 1000, "there", :something]
array_of_hashes = (0...5000).map do 
  hsh = keys.reduce({}) do |hsh, key|
    hsh[key] = values.shuffle.first
    hsh
  end
  hsh[:internal_hash] = keys.reduce({}) do |hsh, key|
    hsh[key] = values.shuffle.first
    hsh
  end
  hsh
end
~~~
