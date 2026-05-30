# Network Analysis - Metrics Explanation

## Graph Overview

| Property | Value |
|----------|-------|
| Graph Type | Undirected, Unweighted |
| Nodes (Countries) | 94 |
| Edges (Similarity Links) | 372 |
| Reference Year | 2022 |
| Edge Definition | Two countries are connected if: `|renewable_share₁ - renewable_share₂| ≤ 10%` AND `|CO₂_per_capita₁ - CO₂_per_capita₂| ≤ 3.0` |
| Average Degree | 7.91 |
| Edge Density | 0.0851 |
| Connected Components | 8 |

---

## 1. Degree Centrality

### Formula

$$
C_D(v) = \frac{\deg(v)}{n - 1}
$$

Where:
- $\deg(v)$ = number of edges incident to node $v$
- $n$ = total number of nodes in the graph

### Interpretation
Degree Centrality measures how many direct connections a node has, normalized by the maximum possible connections. In our energy similarity graph, a high Degree Centrality means a country has a renewable/CO₂ profile that is similar to many other countries — it represents a "typical" or "common" energy profile.

### Top 10 Values

| Country | Degree Centrality | Renewable Share (%) | CO₂ per Capita |
|---------|:-----------------:|:-------------------:|:--------------:|
| Slovakia | 0.172 | 22.67 | 5.77 |
| Mexico | 0.161 | 22.94 | 3.53 |
| Cyprus | 0.161 | 16.92 | 5.31 |
| Hungary | 0.161 | 21.20 | 4.67 |
| Slovenia | 0.151 | 29.62 | 6.02 |
| Thailand | 0.151 | 15.26 | 3.80 |
| France | 0.151 | 24.54 | 4.46 |
| Bosnia and Herzegovina | 0.151 | 37.87 | 6.47 |
| Italy | 0.151 | 36.44 | 5.70 |
| Uzbekistan | 0.151 | 7.74 | 3.41 |

### Interpretation
Countries like **Slovakia**, **Mexico**, and **Cyprus** have the highest degree centrality. This indicates they possess "average" energy profiles — their renewable share (~15-23%) and CO₂ levels (~3.5-5.8 t/capita) are common across many nations, making them highly connected in the similarity network.

---

## 2. Betweenness Centrality

### Formula

$$
C_B(v) = \frac{2}{(n-1)(n-2)} \sum_{s \neq v \neq t} \frac{\sigma_{st}(v)}{\sigma_{st}}
$$

Where:
- $\sigma_{st}$ = total number of shortest paths from node $s$ to node $t$
- $\sigma_{st}(v)$ = number of those shortest paths that pass through node $v$
- $n$ = total number of nodes in the graph
- NetworkX normalizes by default using the factor $2/[(n-1)(n-2)]$ for undirected graphs

### Interpretation
Betweenness Centrality measures how often a node lies on the shortest path between two other nodes. Nodes with high betweenness act as "bridges" or "gatekeepers" between different clusters in the network. In our graph, a high betweenness country connects otherwise dissimilar energy-profile groups.

### Top 10 Values

| Country | Betweenness Centrality |
|---------|:---------------------:|
| Sweden | 0.213 |
| Italy | 0.199 |
| Vietnam | 0.196 |
| Greece | 0.176 |
| Czechia | 0.150 |
| North Macedonia | 0.132 |
| Switzerland | 0.121 |
| Portugal | 0.117 |
| Poland | 0.100 |
| Bosnia and Herzegovina | 0.082 |

### Interpretation
**Sweden** (0.213) and **Italy** (0.199) have the highest betweenness centrality. Sweden has a very high renewable share (~69%), placing it in a cluster of green-energy leaders. Italy (~36% renewable) sits between the high-renewable and moderate-renewable clusters, acting as a bridge. This means these countries are structurally important: removing them would fragment the network and disconnect certain groups of countries from others.

---

## 3. Closeness Centrality

### Formula

$$
C_C(v) = \frac{R(v) - 1}{\sum_{u \in R(v), u \neq v} d(v, u)} \cdot \frac{R(v) - 1}{n - 1}
$$

(Wasserman–Faust normalization for disconnected graphs)

Where:
- $d(v, u)$ = shortest path distance between node $v$ and node $u$
- $R(v)$ = set of nodes reachable from node $v$ (its connected component)
- $n$ = total number of nodes in the graph
- For a fully connected graph $(R(v) = n)$, this simplifies to $C_C(v) = (n-1) / \sum_{u \neq v} d(v, u)$
- NetworkX automatically applies this normalization when the graph has disconnected components

### Interpretation
Closeness Centrality measures how quickly a node can reach all other nodes in the network. High closeness means a country's energy profile is centrally positioned — it can reach every other profile through a small number of similarity steps.

### Top 10 Values

| Country | Closeness Centrality |
|---------|:-------------------:|
| North Macedonia | 0.270 |
| Italy | 0.268 |
| Slovenia | 0.266 |
| Serbia | 0.263 |
| Bosnia and Herzegovina | 0.258 |
| Ireland | 0.255 |
| China | 0.252 |
| Greece | 0.248 |
| Argentina | 0.248 |
| Bulgaria | 0.247 |

### Interpretation
**North Macedonia** (0.270) and **Italy** (0.268) have the highest closeness centrality. This means their energy profiles are "centrally located" — they can reach all other countries in the network via the fewest hops. European countries dominate the top of this list, suggesting European energy profiles form a dense, well-connected core in the global energy landscape.

---

## 4. Analytical Conclusions

1. **European countries dominate centrality metrics** — they appear frequently at the top of all three rankings. This reflects Europe's heterogeneous but interconnected energy landscape, where countries range from high-renewable (Sweden, Norway) to fossil-dependent (Poland, Czechia), creating a dense network.

2. **Sweden and Italy are critical network bridges** — their high betweenness centrality suggests they connect different energy-profile clusters. Sweden connects the "very high renewable" cluster (Nordic countries) with the rest, while Italy bridges Southern and Central European profiles.

3. **Countries with ~20-25% renewable share are most "typical"** — Slovakia, Mexico, Hungary, and France have the highest degree centrality, representing the most common energy profile worldwide: moderate renewable adoption (~20-25%) and moderate CO₂ emissions (~4-6 t/capita).

4. **Geographic patterns emerge** — Similar-profile connections often align with geographic regions (European countries connect to other European countries, Asian to Asian), though our edge definition is purely metric-based, suggesting regional energy policies create shared profiles.
