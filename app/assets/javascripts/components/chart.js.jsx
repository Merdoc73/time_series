class Chart extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      rows: props.rows,
      elementId: props.elementId,
      isAnomaly: props.isAnomaly
    };
  };
  componentWillReceiveProps(nextProps) {
    console.log(this.props);
    console.log(nextProps);
    if (nextProps.rows == [] || nextProps.rows[0] == undefined || nextProps === this.props )
      return
    var options = {};
    coords = nextProps.rows[0].map(function(array) {
      return [array[0], parseFloat(array[1])];
    });
    //data.addRows(coords);
    // chart.draw(data, options);
    console.log('state chart');
    console.log(this.state.chart);
    var chart;
    if(this.state.chart == undefined) {
        chart = new Highcharts.Chart({
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
      this.setState({chart: chart});
    }
    (this.state.chart || chart).update({
        series: [{
          data: coords
        }]}
    );
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
    (this.state.chart || chart).update(
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
        <div id={this.props.elementId} style={{width: '100%'}}></div>
      </div>
    );
  }
}
