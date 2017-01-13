var Base = React.createClass({
  propTypes: {
    equation: React.PropTypes.string,
    coords: React.PropTypes.array,
    pointsCount: React.PropTypes.node
  },

  getInitialState: function() {
    return this.props;
  },

  render: function() {
    return (
      <div>
        equation: <input type='text' onChange={this.handleChangeEquation} />
        points_count: <input type='text' onChange={this.handleChangePointsCount} />
        <div>Evaluation: {this.state.equation}</div>
        <div>Points Count: {this.state.pointsCount}</div>
        <BaseGraph equation={this.state.equation} pointsCount={this.state.pointsCount}/>
        <DeviationGraph equation={this.state.equation} pointsCount={this.state.pointsCount}/>
      </div>
    );
  },
  handleChangeEquation: function(e) {
    this.setState({equation: e.target.value});
  },

  handleChangePointsCount: function(e) {
    this.setState({pointsCount: e.target.value});
  }
})
