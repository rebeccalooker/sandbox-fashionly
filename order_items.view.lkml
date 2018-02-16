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
    value_format_name: usd
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
    hidden: yes
  }

  dimension: is_expensive_item_returned_in_past_30_days {
    type: yesno
    sql: ${sale_price} >= 100.00 and
        DATEDIFF(day, ${returned_date}, current_date) <= 30 ;;
    # hidden: yes
  }

  measure: count_orders_made {
    type: number
    sql: COUNT(${order_id}) ;;
    drill_fields: [
      users.id,
      users.first_name,
      users.last_name,
      order_id]
  }

  measure: count_items_ordered {
    label: "Items Ordered"
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

  measure: total_gross_revenue {
    type: sum
    sql: ${sale_price} ;;
    filters: {
      field: status
      value: "-Cancelled, -Returned"
      }
    value_format_name: usd
  }

  measure: average_gross_revenue {
    type: average
    sql: ${sale_price} ;;
    filters: {
      field: status
      value: "-Cancelled, -Returned"
        }
    value_format_name: usd
  }

  measure: total_gross_margin {
    type: sum
    sql: ${sale_price} - ${inventory_items.cost} ;;
    filters: {
      field: status
      value: "-Cancelled, -Returned"
      }
    value_format_name: usd
    drill_fields: [brand_details*]
  }

  measure: average_gross_margin {
    description: "For order items"
    type: average
    sql: ${sale_price} - ${inventory_items.cost} ;;
    filters: {
      field: status
      value: "-Cancelled, -Returned"
      }
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
    sql: 1.000 * ${items_returned} / ${count_items_ordered} ;;
    value_format_name: percent_2
    drill_fields: [detail*]
  }

  measure: expensive_items_returned_in_past_30_days {
    type: count_distinct
    sql: ${is_expensive_item_returned_in_past_30_days} ;;
    filters: {
      field: is_expensive_item_returned_in_past_30_days
      value: "yes"
      }
    }

  measure: dynamic_order_finances {
    type: number
    label_from_parameter: order_finances
    sql:
      CASE WHEN {% parameter order_finances %} ='total_sale_price' THEN ${total_sale_price}
        WHEN {% parameter order_finances %} ='order_count' THEN ${count_orders_made}
        WHEN {% parameter order_finances %} ='average_sale_price' THEN ${average_sale_price}
        ELSE null
       END ;;
  }

  # ------ Parameters ------
  ## produce "FILTER-ONLY FIELDS" in frontend
  parameter: order_finances {
    allowed_value: {
      label: "Total Sale Price"
      value: "total_sale_price"
    }
    allowed_value: {
      label: "Order Count"
      value: "order_count"
    }
    allowed_value: {
      label: "Average Sale Price"
      value: "average_sale_price"
    }
  }

  parameter: agg_type {
    suggestions: ["Sum", "Average", "Min", "Max"]
    hidden: yes
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

  set: brand_details {
    fields: [
      inventory_items.product_name,
      inventory_items.product_category,
      inventory_items.product_brand,
      inventory_items.product_facebook,
      inventory_items.product_department
    ]
  }
}
