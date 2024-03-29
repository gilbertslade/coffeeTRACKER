w = 960
h = 500
fill = d3.scale.category10()
nodes = d3.range(100).map(Object)

vis = d3.select("#chart").append("svg:svg")
  .attr("width", w)
  .attr("height", h)

force = d3.layout.force()
  .nodes(nodes)
  .links([])
  .size([w, h])
  .start()

node = vis.selectAll("circle.node")
  .data(nodes)
  .enter().append("svg:circle")
  .attr("class", "node")
  .attr("cx", (d) -> d.x)
  .attr("cy", (d) -> return d.y)
  .attr("r", 8)
  .style("fill", (d, i) -> fill(i & 3) )
  .style("stroke", (d, i) -> d3.rgb(fill(i & 3)).darker(2) )
  .style("stroke-width", 1.5)
  .call(force.drag)

vis.style("opacity", 1e-6)
  .transition()
  .duration(1000)
  .style("opacity", 1)

force.on "tick", (e) -> 
  # Push different nodes in different directions for clustering.
  k = 6 * e.alpha
  nodes.forEach (o, i) -> 
    o.x += if i & 2 then k else -k
    o.y += if i & 1 then k else -k
  node.attr("cx", (d) -> d.x )
    .attr("cy", (d) -> d.y )


d3.select("body").on "click", () -> 
  nodes.forEach (o, i) -> 
    o.x += (Math.random() - 0.5) * 40
    o.y += (Math.random() - 0.5) * 40
  force.resume()

