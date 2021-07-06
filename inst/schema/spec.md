This is all highly uncertain and liable to change!

# Intervention names
This is a list of intervention ids represented in the app:

* `none` - no intervention
* `llin` - standard nets
* `irs` - spray
* `irs-llin` - standard nets plus spray
* `llin-pbo` - PBO nets
* `irs-llin-pbo` - PBO nets plus spray
         
# Options

## GET /baseline/options
Returns an object defining baseline options, and how they should be presented to the user. The [DataOptions](./DataOptions.schema.json) objects provided in the request for other endpoints represent selected values of these options. 

Schema: [DynamicFormOptions.schema.json](./DynamicFormOptions.schema.json)

### Example
```json
{
 "controlSections": [
  {
    "label": "Site Inputs",
    "controlGroups": [
      {
        "controls": [
           {
             "name": "population",
             "label": "Population Size",
             "type": "number",
             "required": true,
             "value": 1000,
             "helpText": "The population of the region",
             "min": 1,
             "max": 1e7
             }
          ]
       }
     ]
   }
 ]
}                    
```

## GET /interventions/options
Returns an object defining intervention options and how they should be presented to the user.

Schema: [DynamicFormOptions.schema.json](./DynamicFormOptions.schema.json)

### Example
The schema is the same as for [baseline options](https://github.com/mrc-ide/mintr/blob/master/inst/schema/spec.md#get-baselineoptions)

# Graphs

## POST /graph/prevalence/data
Accepts a set of baseline options and generates a data set for the prevalence graph

Request schema: [DataOptions.schema.json](./DataOptions.schema.json)

Return schema: [Data.schema.json](./Data.schema.json)

### Example
#### Request
```json
{
  "irsFuture": "80%",
  "sprayInput": 1,
  "bitingIndoors": "high",
  "population": 1000
}
```

#### Response
```json
[
  {
    "month": 0,
    "intervention": "none",
    "netUse": 0,
    "irsUse": 0,
    "value": 0.4287
  },
  {
    "month": 0,
    "intervention": "none",
    "netUse": 0,
    "irsUse": 0,
    "value": 0.4119
  },
  {
    "month": 0,
    "intervention": "none",
    "netUse": 0,
    "irsUse": 0,
    "value": 0.6894
  },
  {
    "month": 0,
    "intervention": "none",
    "netUse": 0,
    "irsUse": 0,
    "value": 0.6217
  },
  {
    "month": 0,
    "intervention": "none",
    "netUse": 0,
    "irsUse": 0,
    "value": 0.4716
  },
  {
    "month": 0,
    "intervention": "none",
    "netUse": 0,
    "irsUse": 0,
    "value": 0.8187
  },
  {
    "month": 0,
    "intervention": "none",
    "netUse": 0,
    "irsUse": 0,
    "value": 0.0453
  },
  {
    "month": 0,
    "intervention": "none",
    "netUse": 0,
    "irsUse": 0,
    "value": 0.1402
  },
  ...
]
```

## GET /graph/prevalence/config
Returns an array of graph configuration object for the prevalence graph.

Properties:
* `layout` - a plotly layout object
* `series` - object containing the plotly metadata for the data series
* `metadata` - object containing the information about the data format and how to derive the
series from the data

and optionally:
* `config` - a plotly config object

Schema: [Graph.schema.json](./Graph.schema.json)

Plotly documentation: https://plotly.com/javascript/plotly-fundamentals/

### Example 

```json
{
    "layout": {
           "title": "Projected prevalence in under 5 year olds",
           "xaxis": {
               "title": "years of intervention",
               "showline": true,
               "tickvals": [12, 24, 36],
               "ticktext": [1, 2, 3]
           },
           "yaxis": {
               "title": "prevalence (%)",
               "showline": true,
               "range": [0, 100],
               "autorange": false
           }
    },  
    "metadata": {
          "format": "long",
          "id_col": "intervention",
          "x_col": "month",
          "y_col": "value",
          "settings": ["netUse", "IRSUse"] // which settings to use to filter the data
    },
    "series": [
         {
             "id": "none",
             "name": "No intervention",
             "type": "lines",
             "marker": {"color": "grey"}
         },
         {           
             "id": "llin",
             "name": "Pyrethoid ITN",
             "type": "lines",
             "marker": {"color": "blue"}
         },
         {         
             "id": "llin-pbo",
             "name": "Switch to Pyrethoid-PBO ITN",
             "type": "lines",
             "marker": {"color": "aquamarine"}
         }
    ],
    "config": {
         "editable": true
    }
}
```

## GET /graph/cost/cases-averted/config
Returns an array of graph configuration object for the cost vs cases-averted graph. 

Schema: [Graph.schema.json](./Graph.schema.json)

### Example
The schema is the same as for the [prevalence graph config](https://github.com/mrc-ide/mintr/blob/master/inst/schema/spec.md#get-graphprevalenceconfig)

## GET /graph/cost/per-case/config
Returns an array of graph configuration object for the cost per case averted graph. Schemas as for above.

Schema: [Graph.schema.json](./Graph.schema.json)

### Example
The schema is the same as for the [prevalence graph config](https://github.com/mrc-ide/mintr/blob/master/inst/schema/spec.md#get-graphprevalenceconfig)

# Tables

## POST /table/data
Accepts a set of baseline options and generates a data set that is used by the impact and cost effectiveness
 tables, as well as both the cost effectiveness graphs.

Request schema: [DataOptions.schema.json](./DataOptions.schema.json)

Return schema: [Data.schema.json](./Data.schema.json)

### Example
#### Request
```json
{
  "irsFuture": "80%",
  "sprayInput": 1,
  "bitingIndoors": "high",
  "population": 1000
}
```

#### Response

```json
[
    {
        "intervention": "none",
        "netUse": 20,
        "irsUse": 0,
        "prevYear1": 7.32,
        "prevYear2": 7.34,
        "prevYear3": 7.48,
        "casesAverted": 0

    },
    {
        "intervention": "none",
        "netUse": 40,
        "irsUse": 0,
        "prevYear1": 7.32,
        "prevYear2": 7.34,
        "prevYear3": 7.48,
        "casesAverted": 0
    },
    {
        "intervention": "none",
        "netUse": 60,
        "irsUse": 0,
        "prevYear1": 7.32,
        "prevYear2": 7.34,
        "prevYear3": 7.48
    },
    ...
]
```

## GET /table/impact/config
Returns the list of columns to display in the impact table, along with the column display names

Schema: [TableDefinition.schema.json](./TableDefinition.schema.json)

e.g.
```json
{
    "intervention": "Interventions",
    "netUse": "Net use",
    "prevYear1": "Prevalence Under 5 yrs: Yr 1 post intervention",
    "prevYear2": "Prevalence Under 5 yrs: Yr 2 post intervention",
    "prevYear3": "Prevalence Under 5 yrs: Yr 3 post intervention",
    "casesAverted": "Cases averted across 3 yrs since intervention"
}
```

## GET /table/cost/config
Returns the list of columns to display in the cost effectiveness table, along with the column display names

Schema: [TableDefinition.schema.json](./TableDefinition.schema.json)

e.g.
```json
{
    "intervention": "Interventions",
    "netUse": "Net use",
    "irsUse": "IRS use",
    "casesAverted": "Cases averted across 3 yrs since intervention"
}
```

# Strategising

## POST /strategise
Accepts a maximum budget and a list of regions with parameters and returns a
list of costed strategies (i.e. an optimal set of interventions/regions) for
the maximum budget and 4 other budgets corresponding to 95%, 90%, 85% and 80%
of the maximum.

Request schema: [StrategiseOptions.schema.json](StrategiseOptions.schema.json)

Return schema: [Strategise.schema.json](./Strategise.schema.json)

### Example
#### Request
```json
{
  "budget": 20000,
  "zones": [
    {
      "name": "Region A",
      "baselineSettings": {
        "population": 1000,
        "seasonalityOfTransmission": "seasonal",
        "currentPrevalence": "30%",
        "bitingIndoors": "high",
        "bitingPeople": "low",
        "levelOfResistance": "0%",
        "metabolic": "yes",
        "itnUsage": "0%",
        "sprayInput": "0%"
      },
      "interventionSettings": {
        "netUse": "0.8",
        "irsUse": "0.6",
        "procurePeoplePerNet": 1.8,
        "procureBuffer": 7,
        "priceNetStandard": 1.5,
        "priceNetPBO": 2.5,
        "priceDelivery": 2.75,
        "priceIRSPerPerson": 5.73,
        "budgetAllZones": 2000000,
        "zonal_budget": 500000.05
      }
    }
  ]
}
```

#### Response
```json
[
  {
    "costThreshold": 1,
    "strategy": {
      "cost": 19716.3889,
      "casesAverted": 595,
      "interventions": [
        {
          "zone": "Region A",
          "intervention": "irs-llin"
        }
      ]
    }
  },
  {
    "costThreshold": 0.95,
    "strategy": {
      "cost": 17190,
      "casesAverted": 570,
      "interventions": [
        {
          "zone": "Region A",
          "intervention": "irs"
        }
      ]
    }
  },
  {
    "costThreshold": 0.9,
    …
  },
  {
    "costThreshold": 0.85,
    …
  },
  {
    "costThreshold": 0.8,
    …
  }
]
```
