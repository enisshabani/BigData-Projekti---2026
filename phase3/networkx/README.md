# Pjesa C – Network Analysis (Teoria e Grafeve)

## Platforma e Përdorur

- **NetworkX** (Python) — bibliotekë për analizën e rrjeteve dhe teorinë e grafeve
- **Matplotlib** — për gjenerimin e vizualizimit të grafikut
- **Pandas** — për manipulimin dhe eksportimin e të dhënave

## Instalimi dhe Konfigurimi

```bash
pip install networkx matplotlib pandas
```

Kërkesat minimale: Python 3.8+, NetworkX 2.6+, Pandas 1.3+, Matplotlib 3.4+

## Dataset-i i Përdorur

Burimi: `phase3/shared_data/country_yearly_profile.csv`
- Dataset nga Faza 1 / Faza 2 (OWID — Our World in Data)
- Përmban profilet vjetore të energjisë për 189 shtete
- Filtruar për vitin 2022: **94 shtete** pas heqjes së rreshtave me vlera null
- Kolonat e përdorura: `CountryName`, `ISOCode`, `CO2PerCapita`, `EnergyPerPerson`, `RenewableShare`

## Ndërtimi i Grafikut

| Karakteristikë | Vlera |
|---------------|-------|
| Tipi i Grafikut | I padrejtuar (undirected), i papeshuar (unweighted) |
| Nyjet (Nodes) | 94 shtete |
| Brinjët (Edges) | 372 lidhje ngjashmërie |
| Viti referues | 2022 |
| Densiteti | 0.0851 |
| Komponentë të lidhur | 8 |

### Definimi i Brinjëve (Edges)

Dy shtete lidhen nëse plotësojnë të dy kushtet:
1. Diferenca absolute e përqindjes së energjisë së rinovueshme ≤ 10%
2. Diferenca absolute e CO₂ për kokë banori ≤ 3.0 ton

## Metrikat e Llogaritura

Skripta llogarit tre metrika të centralitetit për secilën nyje:

| Metrika | Formula | Interpretimi |
|---------|---------|-------------|
| **Degree Centrality** | `C_D(v) = deg(v) / (n-1)` | Numri i lidhjeve direkte të një shteti, i normalizuar |
| **Betweenness Centrality** | `C_B(v) = 2/((n-1)(n-2)) · Σ σ_st(v)/σ_st` | Sa shpesh një shtet ndodhet në rrugën më të shkurtë midis dy shteteve të tjera |
| **Closeness Centrality** | `C_C(v) = (R(v)-1)/Σ d(v,u) · (R(v)-1)/(n-1)` | Afërsia mesatare e një shteti me të gjitha shtetet e tjera (Wasserman-Faust për graf të palidhur) |

## Ekzekutimi

```bash
cd phase3/networkx
python network_analysis.py
```

## Output-et e Gjeneruara

| Skedar | Përshkrimi |
|--------|------------|
| `centrality_metrics.csv` | Vlerat e llogaritura për të gjitha metrikat (94 rreshta) |
| `graph_visualization.png` | Vizualizimi i grafikut me spring layout |
| `energy_graph.graphml` | Skedari i grafikut në format GraphML (XML-based) |

## Interpretimi i Rezultateve

- **Sllovakia** ka degree centrality më të lartë (0.172) — profili energjetik më "tipike", i ngjashëm me shumë shtete të tjera
- **Suedia** (0.213) dhe **Italia** (0.199) kanë betweenness centrality më të lartë — veprojnë si "ura" midis grupimeve të ndryshme të profileve energjetike
- **Maqedonia e Veriut** (0.270) dhe **Italia** (0.268) kanë closeness centrality më të lartë — profilet më qendrore në rrjet
- Shtetet evropiane dominojnë të tria renditjet, duke reflektuar një peizazh energjetik heterogjen por të ndërlidhur
