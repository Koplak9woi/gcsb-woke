const text =
    `connection: "bigquery_public_data_looker"
# include all views in this project
include: "*.view"
include: "/z_tests/*.lkml"

explore: airports {
  group_label: "FAA"
}

explore: flights {
  group_label: "FAA"
  description: "Start here for information about flights!"
  join: carriers {
    type: left_outer
    ` +
    'sql_on: ${flights.carrier} = ${carriers.code} ;;' +
    `
    relationship: many_to_one
  }

  join: aircraft {
    type: left_outer
    ` +
    'sql_on: ${flights.tail_num} = ${aircraft.tail_num} ;;' +
    `
    relationship: many_to_one
  }

  join: aircraft_origin {
    from: airports
    type: left_outer
    ` +
    'sql_on: ${flights.origin} = ${aircraft_origin.code} ;;' +
    `
    relationship: many_to_one
    fields: [full_name, city, state, code, map_location]
  }

  join: aircraft_destination {
    from: airports
    type: left_outer
    ` +
    'sql_on: ${flights.destination} = ${aircraft_destination.code} ;;' +
    `
    relationship: many_to_one
    fields: [full_name, city, state, code, map_location]
  }

  join: aircraft_models {
    ` +
    'sql_on: ${aircraft.aircraft_model_code} = ${aircraft_models.aircraft_model_code} ;;' +
    `
    relationship: many_to_one
  }
}


# Place in faa model

explore: +flights {
  query: task1{
    dimensions: [depart_week, distance_tiered]
    measures: [count]
    filters: [flights.depart_date: "2003"]
  }
  
  query: task2{
    dimensions: [aircraft_origin.state]
    measures: [percent_cancelled]
    filters: [flights.depart_date: "2000"]
  }
  
  query: task3{
    dimensions: [aircraft_origin.state]
    measures: [cancelled_count, count]
    filters: [flights.depart_date: "2004"]
  }
  
  query: task4{
    dimensions: [carriers.name]
    measures: [total_distance]
  }
  
  query:task5{
    dimensions: [depart_year, distance_tiered]
    measures: [count]
    filters: [flights.depart_date: "after 2000/01/01"]
  }
}`;

exports.text = text;
