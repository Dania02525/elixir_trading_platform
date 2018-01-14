// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

import {Socket} from "phoenix"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

//import socket from "./socket"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

let channel = socket.channel("trading:xrb:xlm", {})


channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })


var margin = {top: 20, right: 20, bottom: 30, left: 50},
        width = 960 - margin.left - margin.right,
        height = 500 - margin.top - margin.bottom;

var parseDate = d3.timeParse("%d-%b-%y");

var x = techan.scale.financetime()
        .range([0, width]);

var y = d3.scaleLinear()
        .range([height, 0]);

var candlestick = techan.plot.candlestick()
        .xScale(x)
        .yScale(y);

var xAxis = d3.axisBottom()
        .scale(x);

var yAxis = d3.axisLeft()
        .scale(y);

var svg = d3.select("body").append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom)
        .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

var data = [];

channel.on("update", payload => {
  data.shift();
  data.push({
    date: d3.isoParse(payload.data.date),
    open: payload.data.open,
    high: payload.data.high,
    low: payload.data.low,
    close: payload.data.close,
    volume: payload.data.volume
  })
  draw();
})

channel.on("init", payload => {
  data = payload.data.map(function(d) {
      return {
          date: d3.isoParse(d.date),
          volume: d.volume,
          open: d.open,
          high: d.high,
          low: d.low,
          close: d.close
      };
  });

  svg.append("g")
          .attr("class", "candlestick");

  svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + height + ")");

  svg.append("g")
          .attr("class", "y axis")
          .append("text")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr("dy", ".71em")
          .style("text-anchor", "end")
          .text("Price ($)");

  draw();
})


function initData() {
    var i;
    for(i=0;i<199;i++) {
        data.push(generateDatum())
    }

    svg.append("g")
            .attr("class", "candlestick");

    svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")");

    svg.append("g")
            .attr("class", "y axis")
            .append("text")
            .attr("transform", "rotate(-90)")
            .attr("y", 6)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text("Price ($)");

    draw();
}

function beginFeedData() {
    setInterval(function() {
        data.shift();
        data.push(generateDatum());
        console.log(data);
        draw()
    }, 5000)
}

function generateDatum() {
    if(data.length === 0) {
        return {
            date: new Date(),
            open: 40.9,
            high: 41.94,
            low: 40.62,
            close: 41.34,
            volume: 94162358
        }
    }
    var prevData = data[data.length-1]
    var prevTime = prevData.Date;
    var newOpen = randomPriceFrom(prevData.open, randomSign());
    var newHigh = randomPriceFrom(newOpen, 1);
    var newLow = randomPriceFrom(newOpen, -1);

    return {
            date: addMinutes(prevData.date, 5),
            open: newOpen,
            high: newHigh,
            low: newLow,
            close: randomPriceFrom(newOpen, randomSign()),
            volume: prevData.volume
        }
}

function addMinutes(date, minutes) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDay(), date.getHours(), date.getMinutes() + minutes)
}

function randomSign() {
    return (Math.random() < 0.5) ? -1 : 1;
}

function randomPriceFrom(float, sign) {
    var pct = (((Math.random() * 10) + 1) / 100) * sign;
    return float * (1 + pct);
}

function draw() {
    x.domain(data.map(candlestick.accessor().d));
    y.domain(techan.scale.plot.ohlc(data, candlestick.accessor()).domain());

    svg.selectAll("g.candlestick").datum(data).call(candlestick);
    svg.selectAll("g.x.axis").call(xAxis);
    svg.selectAll("g.y.axis").call(yAxis);
}
