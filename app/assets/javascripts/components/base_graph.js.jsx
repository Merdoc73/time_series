var BaseGraph = React.createClass({
  propTypes: {
    equation: React.PropTypes.string,
    coords: React.PropTypes.array,
    pointsCount: React.PropTypes.node
  },

  getInitialState: function() {
    google.charts.load('current', {'packages':['annotationchart']});
    return this.props;
  },

  render: function() {
    return (
      <div>
        equation: <input type='text' onChange={this.handleChangeEquation} />
        points_count: <input type='text' onChange={this.handleChangePointsCount} />
        <div>Evaluation: {this.state.equation}</div>
        <div>Coords: {this.state.coords}</div>
        <div>Points Count: {this.state.pointsCount}</div>
        <button onClick={this.getGraph}>Ololo</button>
        <div id="chart_div"></div>
      </div>
    );
  },
  getGraph: function(e) {
    self = this;
    $.post('/api/base_graph', {equation: self.state.equation, points_count: self.state.pointsCount}, function(data) {
      self.setState(data);
      self.drawChart();
    }, "json");
    return 'ok';
  },
  handleChangeEquation: function(e) {
    this.setState({equation: e.target.value});
  },

  handleChangePointsCount: function(e) {
    this.setState({pointsCount: e.target.value});
  },
  drawChart: function(e) {
    var options = {
      title: 'My Daily Activities'
    };
    var chart = new google.visualization.AnnotationChart(document.getElementById('chart_div'));
    var data = new google.visualization.DataTable();
    data.addColumn('date', 'x');
    data.addColumn('number', 'y');
    coords = this.state.coords.map(function(array){
     return [new Date(array[0]), array[1]];
    });
    data.addRows(coords);
    chart.draw(data, options);
  }
})
