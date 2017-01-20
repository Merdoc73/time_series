class Chart extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      rows: props.rows,
      elementId: props.elementId,
      isAnomaly: props.isAnomaly
    };
  };
  componentWillUpdate(nextProps, nextState) {
    if (nextProps.rows == [] || nextProps.rows[0] == undefined )
      return
    var options = {};
    coords = nextProps.rows[0].map(function(array) {
      return [array[0], parseFloat(array[1])];
    });
    //data.addRows(coords);
    // chart.draw(data, options);
    var chart = new Highcharts.Chart({
      chart: {
        zoomType: 'xy',
	renderTo: nextProps.elementId
      },
      title: {
        text: ''
      },
      plotOptions: {
        series: {
          shadow: false,
          borderWidth: 0,
        }
      },
      xAxis: {
        lineColor: '#999',
        lineWidth: 1,
        tickColor: '#666',
        tickLength: 3,
        title: {
          text: 'X'
        },

      },
      yAxis: {
        minPadding: 0,
        maxPadding: 0,
        lineColor: '#999',
        lineWidth: 1,
        tickColor: '#666',
        tickWidth: 1,
        tickLength: 3,
        gridLineColor: '#ddd',
        title: {
          text: 'Y',
          rotation: 0,
          margin: 50,
        }
      },
      series: [{
        data: coords
      }]
    });
    if(!nextProps.isAnomaly || nextProps.anomalies == null)
      return
    console.log(nextProps.anomalies);
    var arrayAnomalies = nextProps.anomalies.split(';')
    var anomaliesPlots = arrayAnomalies.map(function(range) {
      return {
        color: '#ad1313',
        from: range.split('-')[0],
        to: range.split('-')[1],
      }});
    chart.update(
    {
      xAxis: {
	plotBands: anomaliesPlots
      }
    });
  };

  componentDidUpdate() {
    console.log('updated');
  };
  render() {
    return (
      <div>
        <div id={this.props.elementId}></div>
      </div >
    );
  }
}
