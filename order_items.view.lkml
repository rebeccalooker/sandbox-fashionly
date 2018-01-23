view: order_items {
  sql_table_name: public.order_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
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

  dimension_group: delivered {
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
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
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
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension_group: shipped {
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
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: create_month {
    type: date_month_name
    sql: ${TABLE}.created_at ;;
  }

  measure: orders_made {
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [
      users.id,
      users.first_name,
      users.last_name,
      count]
  }

  measure: count {
    label: "Items Sold"
    type: count
    drill_fields: [detail*]
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [product_pricing*]
  }

  measure: average_sale_price {
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [product_pricing*]
  }

  measure: cumulative_total_sales {
    type: running_total
    sql: ${total_sale_price} ;;
    value_format_name: usd
    drill_fields: [product_pricing*]
  }

  measure: items_returned {
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: returned_time
      value: "-NULL"
    }
    drill_fields: [detail*]
  }

  measure: item_return_rate {
    type: number
    sql: (100.00 * COUNT(${returns.item_id})) / COUNT(${id}) ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.id,
      users.first_name,
      users.last_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }

  set: product_pricing {
    fields: [
      id,
      inventory_items.product_name,
      sale_price,
      inventory_items.cost
    ]
  }
}
