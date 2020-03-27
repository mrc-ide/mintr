This is all highly uncertain and liable to change!

# Data
## POST /data/tab-name/
Accepts a set of baseline options, and returns a data set for the data under the named tab.

Request schema: [DataOptions.schema.json](./DataOptions.schema.json)

Return schema: [Data.schema.json](./Data.schema.json)

### Example
#### Request
```
{
  "irs_future": "80%",
  "sprayInput": 1,
  "biting_indoors": "high",
  "population": 1000
}
```

#### Response
```
[
    {
        "intervention": "none",
        "net_use": 20,
        "prev_year_1": 7.32,
        "prev_year_2": 7.34,
        "prev_year_3": 7.48,
        "cases_averted": 0,
        "cases_averted_high": 0,
        "cases_averted_low": 0,
    },
    {
        "intervention": "none",
        "net_use": 40,
        "prev_year_1": 7.32,
        "prev_year_2": 7.34,
        "prev_year_3": 7.48,
        "cases_averted": 0,
        "cases_averted_high": 0,
        "cases_averted_low": 0,
    },
    {
        "intervention": "ITN",
        "net_use": 20,
        "prev_year_1": 5.32,
        "prev_year_2": 5.34,
        "prev_year_3": 5.48,
        "cases_averted": 51,
        "cases_averted_high": 60,
        "cases_averted_low": 50,
    },
    {
        "intervention": "ITN",
        "net_use": 40,
        "prev_year_1": 4.32,
        "prev_year_2": 4.34,
        "prev_year_3": 4.48,
        "cases_averted": 52,
        "cases_averted_high": 62,
        "cases_averted_low": 50,
    },
    {
        "intervention": "PBO",
        "net_use": 20,
        "prev_year_1": 6.32,
        "prev_year_2": 6.34,
        "prev_year_3": 6.48,
        "cases_averted": 61,
        "cases_averted_high": 70,
        "cases_averted_low": 60,
    },
    {
        "intervention": "PBO",
        "net_use": 40,
        "prev_year_1": 5.32,
        "prev_year_2": 5.34,
        "prev_year_3": 5.48,
        "cases_averted": 62,
        "cases_averted_high": 72,
        "cases_averted_low": 60,
    }
]
```

# Tables
## GET /table/:tab-name/
Returns metadata about the columns for the table to be displayed under this tab.

Schema: [TableDefinition.schema.json](./TableDefinition.schema.json)

```
[
    {"id": "intervention", "name": "Interventions"},
    {"id": "net_use", "name": "Net use"},
    {"id": "prev_year_1", "name": "Prevalence Under 5 yrs: Yr 1 post intervention"},
    {"id": "prev_year_2", "name": "Prevalence Under 5 yrs: Yr 2 post intervention"},
    {"id": "prev_year_3", "name": "Prevalence Under 5 yrs: Yr 3 post intervention"},
    {"id": "cases_averted", "name": "Cases averted across 3 yrs since intervention"}
]
```

# Graphs

## GET /graphs/:tab-name/
Returns an array of graph metadata objects for the named tab. Each graph metadata object must have:
* an id
* a plotly layout object
* a data object containing all the plotly metadata for the data series as well as the columns defining the series

and optionally:
* a plotly config object

Schema: [Graphs.schema.json](./Graphs.schema.json)

Plotly documentation: https://plotly.com/javascript/plotly-fundamentals/

### Example 
```
[
    {
        "id": "prev",
        "layout": {
               "title": "Projected prevalence in under 5 year olds",
               "xaxis": {
                   "title": 'years of intervention',
                   "showline": true,
                   "tickvals": ["prev_year_1", "prev_year_2", "prev_year_3"],
                   "ticktext": [1, 2, 3],
               },
               "yaxis": {
                   "title": 'prevalence (%)',
                   "showline": true,
                   "range": [0, 100],
                   "autorange": false
               }
        },
        "data": [
             {
                 cols: ["prev_year_1", "prev_year_2", "prev_year_3"],
                 id: "none",
                 name: "No intervention",
                 type: "lines",
                 marker: {color: "grey"}
             },
             {
                 cols: ["prev_year_1", "prev_year_2", "prev_year_3"],
                 id: "ITN",
                 name: "Pyrethoid ITN",
                 type: "lines",
                 marker: {color: "blue"}
             },
             {
                 cols: ["prev_year_1", "prev_year_2", "prev_year_3"],
                 id: "PBO",
                 name: "Switch to Pyrethoid-PBO ITN",
                 type: "lines",
                 marker: {color: "aquamarine"}
             }
        ],
        "config": {
            { "editable": true }
        } 
    },
    {
        "id": "cases_averted",
        "tab": "impact",
        "layout": {
               "title": "Clinical cases averted per 1,000 people per year",
               "yaxis": {
                   "showline": true,
                   "range": [0, 300],
                   "autorange": false
               },
                "xAxis": {
                    "title": "intervention",
                    "showline": true,
                    "tickvals": ["ITN", "PBO", "IRS"],
                    "ticktext": ["ITN", "PBO", "IRS"]
                }
               "showlegend": true
        },
        "data": [
            {  "x": ["ITN"],
               "cols": ["cases_averted"],
               "id": "ITN",
               "type": "bar",
               "name": "Pyrethoid ITN",
               "marker": {
                   color: "blue",
                   opacity: 0.5,
               },
               "error_y": {
                   "type": "data",
                   "cols": ["cases_averted_high"],
                   "colsminus": ["cases_averted_low"],
                   "visible": true,
                   "thickness": 1.5,
                   "width": 0,
                   "opacity": 1
               }
            }
            {
                "x": ["PBO"],
                "cols": ["cases_averted"],
                "id": "PBO",
                "type": "bar",
                "name": "Switch to Pyrethoid-PBO ITN",
                "marker": {
                    "color": "aquamarine",
                    "opacity": 0.5,
                },
                "error_y": {
                    "type": "data",
                    "cols": ["cases_averted_high"],
                    "colsminus": ["cases_averted_low"],
                    "visible": true,
                    "thickness": 1.5,
                    "width": 0,
                    "opacity": 1
                }
            }
        ]
    }

]
```