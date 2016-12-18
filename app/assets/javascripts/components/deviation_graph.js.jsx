var DeviationGraph = React.createClass({
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
        <div>Points Count: {this.state.pointsCount}</div>
        <button onClick={this.getGraph}>Ololo</button>
        <GoogleChart elementId='deviation_chart_div' rows={[this.state.coords]} />
      </div>
    );
  },
  getGraph: function(e) {
    self = this;
    $.post('/api/deviation_graph', {equation: self.state.equation, points_count: self.state.pointsCount}, function(data) {
      self.setState(data);
    }, "json");
    return 'ok';
  },
  handleChangeEquation: function(e) {
    this.setState({equation: e.target.value});
  },

  handleChangePointsCount: function(e) {
    this.setState({pointsCount: e.target.value});
  }
})
