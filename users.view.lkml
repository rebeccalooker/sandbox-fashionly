view: users {
  sql_table_name: public.users ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_group {
    type: tier
    tiers: [15, 26, 36, 51, 66]
    style: integer
    sql: ${age} ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
    hidden: yes
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
    hidden: yes
  }

  dimension: customer_location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  dimension: is_new_customer {
    type: yesno
    sql: DATEDIFF(day, ${created_date}, current_date) <= 90 ;;
  }

  measure: count {
    type: count
    drill_fields: [user_details*, events.count]
  }

  measure: number_of_customers_returning_items {
    type: count_distinct
    sql: ${returns.user_id} ;;
    drill_fields: [user_details*]
  }

  measure: percent_of_users_with_returns {
    type: count_distinct
    sql: ${returns.user_id} / ${id} ;;
    value_format_name: percent_2
    drill_fields: [user_details*, order_items.order_id, inventory_items.product_name]
  }

  measure: average_spend_per_customer {
    type: number
    sql: SUM(${order_items.sale_price}) / COUNT(${id}) ;;
    value_format_name: usd
    drill_fields: [user_details*]
  }

  set: user_details {
    fields: [
      id,
      first_name,
      last_name,
      age_group,
      gender,
      order_items.count
    ]
  }
}
