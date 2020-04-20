This is all highly uncertain and liable to change!

# Graphs

## POST /graph/prevalence/data
Accepts a set of baseline options and generates a data set for the prevalence graph

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
    "month": 0,
    "intervention": "none",
    "net_use": 0,
    "irs_use": 0,
    "prevalence": "low",
    "resistance": 0.2,
    "value": 0.4287
  },
  {
    "month": 0,
    "intervention": "none",
    "net_use": 0,
    "irs_use": 0,
    "prevalence": "low",
    "resistance": 0.4,
    "value": 0.4119
  },
  {
    "month": 0,
    "intervention": "none",
    "net_use": 0,
    "irs_use": 0,
    "prevalence": "low",
    "resistance": 0.6,
    "value": 0.6894
  },
  {
    "month": 0,
    "intervention": "none",
    "net_use": 0,
    "irs_use": 0,
    "prevalence": "low",
    "resistance": 0.8,
    "value": 0.6217906241600673
  },
  {
    "month": 0,
    "intervention": "none",
    "net_use": 0,
    "irs_use": 0,
    "prevalence": "med",
    "resistance": 0.2,
    "value": 0.4716
  },
  {
    "month": 0,
    "intervention": "none",
    "net_use": 0,
    "irs_use": 0,
    "prevalence": "med",
    "resistance": 0.4,
    "value": 0.8187
  },
  {
    "month": 0,
    "intervention": "none",
    "net_use": 0,
    "irs_use": 0,
    "prevalence": "med",
    "resistance": 0.6,
    "value": 0.0453
  },
  {
    "month": 0,
    "intervention": "none",
    "net_use": 0,
    "irs_use": 0,
    "prevalence": "med",
    "resistance": 0.8,
    "value": 0.1402
  },
  ...
]
```

## GET /graph/prevalence/config
Returns an array of graph configuration object for the prevalence graph.

Properties:
* an id
* a plotly layout object
* a data object containing all the plotly metadata for the data series as well as the columns defining the series

and optionally:
* a plotly config object

Schema: [Graphs.schema.json](./Graphs.schema.json)

Plotly documentation: https://plotly.com/javascript/plotly-fundamentals/

### Example 
```
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
}

```

# Tables

## POST /table/impact/data
Accepts a set of baseline options and generates a data set for the prevalence graph. 
Each item in the array should have properties corresponding to table columns.

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
        "irs_use": 0,
        "prev_year_1": 7.32,
        "prev_year_2": 7.34,
        "prev_year_3": 7.48,
        "cases_averted": 0

    },
    {
        "intervention": "none",
        "net_use": 40,
        "irs_use": 0,
        "prev_year_1": 7.32,
        "prev_year_2": 7.34,
        "prev_year_3": 7.48,
        "cases_averted": 0
    },
    {
        "intervention": "none",
        "net_use": 60,
        "irs_use": 0,
        "prev_year_1": 7.32,
        "prev_year_2": 7.34,
        "prev_year_3": 7.48
    },
    ...
]
```

## GET /table/impact/config
Returns about the column display names

Schema: [TableDefinition.schema.json](./TableDefinition.schema.json)

```
[
    {"intervention": "Interventions"},
    {"net_use": "Net use"},
    {"prev_year_1": "Prevalence Under 5 yrs: Yr 1 post intervention"},
    {"prev_year_2": "Prevalence Under 5 yrs: Yr 2 post intervention"},
    {"prev_year_3": "Prevalence Under 5 yrs: Yr 3 post intervention"},
    {"cases_averted": "Cases averted across 3 yrs since intervention"}
]
```