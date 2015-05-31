$title: Depth
$author: Max
$tags: gem, ruby, misc
$published: true
$last_updated_at: 2015-03-31 23:04:35

###We need to go deeper

The title's an inception quote, not something rude. With the potential
misunderstanding cleared up I&#39;d like to introduce <a href="https://github.com/maxdupenois/depth">Depth</a>. So I will. Article reader this is <a href="https://github.com/maxdupenois/depth">Depth</a>, <a href="https://github.com/maxdupenois/depth">Depth</a> this is article reader. Okay, as witty article lead-ins go this one ranks near the bottom of the pile so I'll bail on extending the joke. Depth is a
utility gem I recently built for handling complex hashes, that is hashes that
contain nested hashes and arrays (essentially JSON like structures). I had come
across some code for parsing one of these hashes and needed to do a bit more with
it, ater playing around a bit I took what I'd learned and built Depth to handle
the heavy lifting.

###There are already gems for this.

Yes, yes there are, and this looks like a case of NIH. However the original code
for the project I was working on isn't as powerful as Depth and as such Depth
is less of a case of re-inventing the wheel and more me wanting to see how
I would go about creating such a gem and how it would work.

###How complicated could it be?

That's what I thought too, however I set myself the constraint of not using
recursion. Depth wouldn't know the potential complexity of a given hash so
there's no prior knowledge of how deep you could end up going. In such a cases
I don't like using recursion, the probability of hitting a
`StackOverflowError` may be small\*, but I will always choose to avoid it given
the option.

\* _As was pointed out by <a href="http://samwho.co.uk/">Sam</a> if you end up with data structures that nested you have other potential issues._

###How does you use it?

It's a gem, install it and play around. There's some reasonably good documentation
on the <a href="https://github.com/maxdupenois/depth/blob/master/README.md">README</a> so there's little point repeating it here.

###How does it work?

That's the question I actually want to answer.

```ruby
def enumerate
  root = Node.new(nil, nil, base)
  current = root
  begin
    if current.next?
      current = current.next
    elsif !current.root?
      yield(current)
      current = current.parent
    end
  end while !current.root? || current.next?
  self
end
```

The above is the key method to getting the code to enumerate through the
hash. It builds a tree from the root element up until it hits a leaf node,
then it heads back down the tree until it comes to a branch point. This
is easier to understand with some examples:

```ruby
complex_hash = { hello: [:a, :b, { c: { woo: 'rargh' } }], there: 'friend' }
```

1. First, we set up the root node: `{ hello: [:a, :b, c: { woo: 'rargh' }], there: 'friend' }`.
2. Then we start iterating, the first key/index of the current node is `:hello` so we start there and get the next node `[:a, :b, { c: { woo: 'rargh' } }]`.
3. Iterating again we move on to `:a`.
4. `:a` is a leaf node so we `yield` and move back to the parent node: `[:a, :b, { c: { woo: 'rargh' } }]`
5. We've already explored the first key/index of this node so we move on to the second `:b`
6. ... And I think you get the picture from there.

The above will yield in sequence: `:a`, `:b`, `'rargh'`, `{ woo: 'rargh' }`, `{ c: { woo: 'rargh' }`, `[:a, :b, { c: { woo: 'rargh' } }]`, `friend` and finally `{ hello: [:a, :b, { c: { woo: 'rargh' } }], there: 'friend' }`. For conveniance we can also get the key or index that has the yielded value from each node, but you can read more about the specifics of use in the github README.

Importantly the tree is built as you parse, so if you are looking for a specific 
node you can break once you've found it and not have a large tree structure
squatting in memory.

###What will it be used for?

Anything, nothing? For me it was about building the enumerator in such a way
that it was non recursive and learning a neat way in which to do it. If anyone
uses it for anything that's awesome but not expected. It was fun to build,
if you have any comments about the code, stucture or quality, I would genuinely
love to read them so please add them as issues to github.

