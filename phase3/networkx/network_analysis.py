from pathlib import Path

import matplotlib.pyplot as plt
import networkx as nx
import pandas as pd

SCRIPT_DIR = Path(__file__).resolve().parent
SHARED_DATA = SCRIPT_DIR.parents[1] / "phase3" / "shared_data"
CSV_PATH = SHARED_DATA / "country_yearly_profile.csv"
OUTPUT_DIR = SCRIPT_DIR

REFERENCE_YEAR = 2022
RENEWABLE_THRESHOLD = 10.0
CO2_THRESHOLD = 3.0

print("=" * 60)
print("Phase 3C - Network Analysis (NetworkX)")
print("Energy Country Similarity Graph")
print("=" * 60)

print(f"\nLoading data from: {CSV_PATH}")
df = pd.read_csv(CSV_PATH)

print(f"Total rows: {len(df)}")
print(f"Columns: {list(df.columns)}")

year_df = df[df["Year"] == REFERENCE_YEAR].copy()
print(f"\nFiltering to year {REFERENCE_YEAR}: {len(year_df)} countries")

year_df = year_df.dropna(subset=["CountryName", "RenewableShare", "CO2PerCapita"])
print(f"After dropping nulls: {len(year_df)} countries")

print("\n--- Building Country Similarity Graph ---")
G = nx.Graph()

for _, row in year_df.iterrows():
    G.add_node(
        row["CountryName"],
        iso_code=row["ISOCode"],
        co2_per_capita=row["CO2PerCapita"],
        energy_per_person=row["EnergyPerPerson"],
        renewable_share=row["RenewableShare"],
    )

countries = year_df.to_dict("records")
edge_count = 0
for i in range(len(countries)):
    for j in range(i + 1, len(countries)):
        c1, c2 = countries[i], countries[j]
        renew_diff = abs(c1["RenewableShare"] - c2["RenewableShare"])
        co2_diff = abs(c1["CO2PerCapita"] - c2["CO2PerCapita"])
        if renew_diff <= RENEWABLE_THRESHOLD and co2_diff <= CO2_THRESHOLD:
            G.add_edge(c1["CountryName"], c2["CountryName"])
            edge_count += 1

print(f"Nodes: {G.number_of_nodes()}")
print(f"Edges: {G.number_of_edges()}")

print("\n--- Computing Centrality Metrics ---")

deg_cent = nx.degree_centrality(G)
between_cent = nx.betweenness_centrality(G)
close_cent = nx.closeness_centrality(G)

metrics_df = pd.DataFrame(
    {
        "Country": list(G.nodes()),
        "Degree_Centrality": [deg_cent[n] for n in G.nodes()],
        "Betweenness_Centrality": [between_cent[n] for n in G.nodes()],
        "Closeness_Centrality": [close_cent[n] for n in G.nodes()],
    }
)

metrics_df["RenewableShare"] = metrics_df["Country"].map(
    {n: G.nodes[n]["renewable_share"] for n in G.nodes()}
)
metrics_df["CO2PerCapita"] = metrics_df["Country"].map(
    {n: G.nodes[n]["co2_per_capita"] for n in G.nodes()}
)

metrics_df = metrics_df.sort_values("Degree_Centrality", ascending=False)

csv_output = OUTPUT_DIR / "centrality_metrics.csv"
metrics_df.to_csv(csv_output, index=False)
print(f"\nMetrics saved to: {csv_output}")

print("\n--- Top 10 Countries by Degree Centrality ---")
print(metrics_df[["Country", "Degree_Centrality", "RenewableShare", "CO2PerCapita"]].head(10).to_string(index=False))

print("\n--- Top 10 Countries by Betweenness Centrality ---")
top_between = metrics_df.sort_values("Betweenness_Centrality", ascending=False)
print(top_between[["Country", "Betweenness_Centrality"]].head(10).to_string(index=False))

print("\n--- Top 10 Countries by Closeness Centrality ---")
top_close = metrics_df.sort_values("Closeness_Centrality", ascending=False)
print(top_close[["Country", "Closeness_Centrality"]].head(10).to_string(index=False))

print("\n--- Generating Visual Graph ---")

node_sizes = [G.nodes[n]["co2_per_capita"] * 40 + 100 for n in G.nodes()]
renewable_values = [G.nodes[n]["renewable_share"] for n in G.nodes()]

pos = nx.spring_layout(G, k=0.5, iterations=50, seed=42)

fig, ax = plt.subplots(figsize=(20, 16))

cmap = plt.cm.RdYlGn
nodes_plot = nx.draw_networkx_nodes(
    G,
    pos,
    node_size=node_sizes,
    node_color=renewable_values,
    cmap=cmap,
    alpha=0.85,
    ax=ax,
)
nx.draw_networkx_edges(G, pos, alpha=0.15, width=0.5, ax=ax)

top_nodes = sorted(deg_cent, key=deg_cent.get, reverse=True)[:20]
label_subset = {n: n for n in top_nodes}
nx.draw_networkx_labels(G, pos, labels=label_subset, font_size=7, ax=ax)

cbar = plt.colorbar(nodes_plot, ax=ax, shrink=0.3)
cbar.set_label("Renewable Energy Share (%)", fontsize=12)

ax.set_title(
    f"Energy Country Similarity Network ({REFERENCE_YEAR})\n"
    f"Nodes = Countries | Edges = Similar renewable & CO2 profiles\n"
    f"Node size ∝ CO₂ per capita | Color = Renewable share %",
    fontsize=14,
)
ax.axis("off")

viz_output = OUTPUT_DIR / "graph_visualization.png"
plt.savefig(viz_output, dpi=150, bbox_inches="tight")
print(f"Visualization saved to: {viz_output}")
plt.close()

for node, (x, y) in pos.items():
    G.nodes[node]["x"] = x
    G.nodes[node]["y"] = y

graphml_output = OUTPUT_DIR / "energy_graph.graphml"
nx.write_graphml(G, graphml_output)
print(f"GraphML saved to: {graphml_output}")

print("\n" + "=" * 60)
print("Network Analysis Complete!")
print("=" * 60)

n_nodes = G.number_of_nodes()
n_edges = G.number_of_edges()
avg_degree = sum(dict(G.degree()).values()) / n_nodes if n_nodes > 0 else 0
print(f"\nSummary:")
print(f"  Graph type: Undirected, Unweighted")
print(f"  Nodes (countries): {n_nodes}")
print(f"  Edges (similarity links): {n_edges}")
print(f"  Avg degree: {avg_degree:.2f}")
print(f"  Edge density: {nx.density(G):.4f}")
print(f"  Connected components: {nx.number_connected_components(G)}")
