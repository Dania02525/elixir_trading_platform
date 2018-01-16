<template>
  <div class="container-fluid">
    <div class="row">
      <div class="col-lg-8" id="graph-placeholder"></div>
      <div class="col-lg-4">
        <table class="table orders">
          <tbody>
            <tr v-for="order in sellOrders">
              <td>{{ order.price }}</td>
              <td>{{ order.quantity }}</td>
            </tr>
            <tr class="table-active">
              <th>{{ marketPrice }}</th>
              <th></th>
            </tr>
            <tr v-for="order in buyOrders">
              <td>{{ order.price }}</td>
              <td>{{ order.quantity }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div class="row">
      <div class="col-lg-8">
        <h4>Open Orders</h4>
        <table class="table open-orders">
          <thead>
            <th>Type</th>
            <th>Date</th>
            <th>Quantity</th>
            <th>Price</th>
            <th></th>
          </thead>
          <tbody>
            <tr v-for="order in myOrders">
              <td>{{ order.type }} </td>
              <td>{{ order.date_string }}</td>
              <td>{{ order.quantity }}</td>
              <td>{{ order.price }}</td>
              <td><button type="button" class="btn btn-outline-danger btn-sm">Cancel</button></td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="col-lg-4">
        <create-order-widget></create-order-widget>
      </div>
    </div>
  </div>
</template>

<script>
import {Socket} from "phoenix"
import CreateOrderWidget from './create-order-widget.vue'

export default {
  data: function() {
    return {
      graphData: [],
      orders: {
        sells: [],
        buys: []
      },
      marketPrice: 0,
      myOrders: [],
      socket: null,
      channel: null,
      tradingChannel: "trading:xrb:xlm",
      graphConstants: {
        margin: {top: 20, right: 20, bottom: 30, left: 50},
        width: null,
        height: null,
        x: null,
        y: null,
        candlestick: null,
        xAxis: null,
        yAxis: null,
        svg: null
      }
    }
  },
  computed: {
    sellOrders: function() {
      let marketPrice = this.marketPrice;
      return this.orders.sells.sort(function(a, b) {
        return (a.price - marketPrice) - (b.price - marketPrice)
      }).slice(0, 5).sort(function(a, b) {
        return b.price - a.price
      })
    },
    buyOrders: function() {
       let marketPrice = this.marketPrice;
      return this.orders.buys.sort(function(a, b) {
        return (marketPrice - a.price) - (marketPrice - b.price)
      }).slice(0, 5).sort(function(a, b) {
        return b.price - a.price
      })
    }
  },
  methods: {
    draw: function() {
      this.graphConstants.x.domain(this.graphData.map(this.graphConstants.candlestick.accessor().d));
      this.graphConstants.y.domain(techan.scale.plot.ohlc(this.graphData, this.graphConstants.candlestick.accessor()).domain());

      this.graphConstants.svg.selectAll("g.candlestick").datum(this.graphData).call(this.graphConstants.candlestick);
      this.graphConstants.svg.selectAll("g.x.axis").call(this.graphConstants.xAxis);
      this.graphConstants.svg.selectAll("g.y.axis").call(this.graphConstants.yAxis);
    }
  },
  components: {
    'create-order-widget': CreateOrderWidget
  },
  mounted: function() {
    this.graphConstants.width = 1100 - this.graphConstants.margin.left - this.graphConstants.margin.right;
    this.graphConstants.height = 500 - this.graphConstants.margin.top - this.graphConstants.margin.bottom;
    this.graphConstants.x = techan.scale.financetime().range([0, this.graphConstants.width]);
    this.graphConstants.y = d3.scaleLinear().range([this.graphConstants.height, 0]);
    this.graphConstants.candlestick = techan.plot.candlestick()
                                        .xScale(this.graphConstants.x)
                                        .yScale(this.graphConstants.y);

    this.graphConstants.xAxis = d3.axisBottom().scale(this.graphConstants.x);
    this.graphConstants.yAxis = d3.axisLeft().scale(this.graphConstants.y);
    this.graphConstants.svg = d3.select("#graph-placeholder").append("svg")
            .attr("width", this.graphConstants.width + this.graphConstants.margin.left + this.graphConstants.margin.right)
            .attr("height", this.graphConstants.height + this.graphConstants.margin.top + this.graphConstants.margin.bottom)
            .append("g")
            .attr("transform", "translate(" + this.graphConstants.margin.left + "," + this.graphConstants.margin.top + ")");


    this.graphConstants.svg.append("g").attr("class", "candlestick");

    this.graphConstants.svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + this.graphConstants.height + ")");

    this.graphConstants.svg.append("g")
            .attr("class", "y axis")
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 6)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text("Amount");

    this.socket = new Socket("/socket", {params: {token: window.userToken}})
    this.socket.connect();
    this.channel = this.socket.channel(this.tradingChannel, {})

    // channel calbacks
    this.channel.on("update_graph", payload => {
      this.graphData.shift();
      this.graphData.push({
        date: d3.isoParse(payload.graph_data.iso_date),
        open: payload.graph_data.open,
        high: payload.graph_data.high,
        low: payload.graph_data.low,
        close: payload.graph_data.close,
        volume: payload.graph_data.volume
      })
      this.draw();
    })

    this.channel.on("update_orders", payload => {
      this.marketPrice = payload.market_price;
      this.orders.sells = payload.order_data.sells;
      this.orders.buys = payload.order_data.buys;
    })

    this.channel.on("init", payload => {
      this.graphData = payload.graph_data.map(function(d) {
          return {
              date: d3.isoParse(d.iso_date),
              volume: d.volume,
              open: d.open,
              high: d.high,
              low: d.low,
              close: d.close
          };
      });

      this.marketPrice = payload.market_price;
      this.orders.sells = payload.order_data.sells;
      this.orders.buys = payload.order_data.buys;
      this.myOrders = payload.order_data.my_orders;
      this.draw();
    })

    // join the websockets channel
    this.channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    return;
  }
}

</script>
