---
layout: post
title: How to represent runs/lifts on mountain resorts
date: 2022-03-20 13:30:10.000000000 +00:00
tag: Tech
image: assets/images/2022-03-20-how-to-represent-runs-lifts-on-mountain-resorts.jpg
---
## Conclusion

Runs are just a partially ordered set of run segments, nodes, and metadata.
Lifts are another partially ordered set of lift segments and nodes. The Nodes are shared with runs, but the segments aren't.

If you know about Git, a run segment node is equivalent to a git commit, and a run is very similar to a set of commits in a branch, but can exclude some of commits from the inception.

## Motivation

A run is the main component of a mountain resort. It's also called as piste, slope, or trail. A mountain resort is also called as ski hill, snowboard resort, or simply mountain. All the runs are one-way because snowboard can only go downhill with the following 2 exceptions: hiking up or ride up with using previous downhill momentum.

Unlike city maps, mountain resort maps are usually ambiguous but where you can actually go really depends on the topological structure of the runs. Not only the connectivity but also the difficulty of each segments are unknown, which makes snowboarders hard to navigate. It's particularly problematic when the mountain is foggy, since you can't find a signboard, and GPS is not necessarily accurate on a mountain. Therefore we need a data structure that represents runs, along with lifts.

## Example: Grouse mountain "The Cut"

<https://www.grousemountain.com/mountain-map/winter>
<https://files.grousemountain.com/WinterMap_Website/Trail%20Map%20Web.pdf>

Where can you get to the main green run "The Cut" from Peak Chalet, without taking any chairlifts?

* Hike up to Streaming Eagle Chair top (right)
* Hike up to Streaming Eagle Chair top (left), ride secret side entrance to The Cut
* Ride Chalet Road, and turn right
* Ride Paper Trail, which merges to The Cut
* Ride Chalet Road, Side Cut, and merge to The Cut without going to Lower Side Cut
* Ride Chalet Road, Side Cut, Lower Side Cut, and merge to The Cut
* Ride Chalet Road, Upper Buckhorn, Skyline, and merge to the Cut
* Ride Chalet Road, Centennial, Skyline, and merge to the Cut
* Ride Chalet Road, Centennial, Dogleg, Skyline, and merge to the Cut
* Ride Chalet Road, Expo, Skyline, and merge to the Cut
* Hike up to Streaming Eagle Chair top, ride Expo, Skyline, and merge to the Cut
* Hike up to Streaming Eagle Chair top, ride Expo Glades, Skyline, and merge to the Cut
* Hike up to Streaming Eagle Chair top, ride the secret run above Expo, and merge to the Cut

There are so many options. I made the list manually by looking at the map, but it's hard to make for each runs and compare with them.

Let's breakdown The Cut.

* (1a). Screaming Eagle top to Chalet Road (main)
* (1b). Screaming Eagle top to Chalet Road (side)
* (1c). Expo top to Chalet Road
* (2). Chalet Road to Paper Trail side entrance
* (3). Paper Trail side entrance to Side Cut merge
* (4). Side Cut merge to Paper Trail exit
* (5). Skyline merge
* (6). Screaming Eagle bottom

This list of segments can be used as a building block to create the list of routes to The Cut, or other routes.

![](/assets/images/2022-03-20-drawing.jpg)
