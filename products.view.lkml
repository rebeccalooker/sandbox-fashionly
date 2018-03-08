view: products {
  sql_table_name: public.products ;;

# ------ Dimensions ------
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    hidden: yes
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
    link: {
      label: "{{ value }} Dashboard"
      url: "https://sandboxcl.dev.looker.com/dashboards/484?Brand%20Name={{ value }}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
    link: {
      label: "{{ value }} Dashboard"
      url: "https://sandboxcl.dev.looker.com/dashboards/484?Category={{ value }}"
      icon_url: "http://www.looker.com/favicon.ico"
    }
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: distribution_center_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.distribution_center_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

# ------ Measures ------
  measure: count {
    type: count
    drill_fields: [id, name
      , distribution_centers.id
      , distribution_centers.name
      , inventory_items.count
      ]
  }
}
