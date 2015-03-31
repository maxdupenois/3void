$title: Bemazed
$author: Max
$tags: games, node, wip
$published: false

###Not a shortening of Be Amazed...

The name came from the idea of being bemused, but it&#39;s a game about mazes,
clever right? Yeah not really, sorry but the name just feels right now so it&#39;s
sticking. Anyway, I wanted to build a game and this time see if I can finish the
thing (not something I have a winning track record of). This one arose from me
wondering about whether or not I could come up with a decent maze generation
engine. There are a bunch of other ideas and mechanics I have and I&#39;ll expand
on those over a series of blog posts.

###Why post at all?

This is a good question and mostly these posts are an experiment to see if they
can help me keep the game on track by writing about my ideas and holding myself
to weekly updates.

###Where do we begin?

For this first post I thought it'd be cool to give an overview of the first
idea I had for the maze generation and why it went a bit pants. 

As it's supposed to be a maze it should have a start and an end point and
it should be, preferably, somewhat difficult to find the way from one to
another. So first I thought about the space in which the maze exists as a
a cartesian bounded plane (the plan is to stick to 2D at the moment), and
looked for ways to create a random start and finish with a guaranteed minimum
distance. There are many sensible ways in which this can be accomplished and I 
opted to use none of them. First I split the plane into a 3x3 grid:

~~~
 1 | 2 | 3
---|---|---
 4 | 5 | 6
---|---|---
 7 | 8 | 9
~~~
_one I made earlier_

The start point would be generated in any grid cell except number 5 and
the finish point could appear in any grid that has a minimum manhattan 
distance of 3 from the start cell.

~~~
 o | 2 | 3     1 | 2 | x
---|---|---   ---|---|---
 4 | 5 | x     o | 5 | 6 
---|---|---   ---|---|---
 7 | x | x     7 | 8 | x
~~~
_o = start, x = possible finish_

The initial implementation of this had an issue (and in writing this I've
come up with a better implementation idea). That issue being that I hadn't
removed any cells when attempting to find where to place the finish point meaning
that random process could take far longer than you'd necessarily expect. Hold on, 
fixed it, see this article is helping already.

Choosing random points within the chosen start and finish cells gives us a start
and end point with a guaranteed reasonable distance apart. Cool, now what.

###Building the path

I didn't want to have to build the maze by adding paths to the start point and
each other until some previously determined complexity and then seeing if I could
make it to the finish with out crossing too many existing paths.


