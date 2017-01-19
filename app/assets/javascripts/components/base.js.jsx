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
        График: <input type='text' onChange={this.handleChangeEquation} /> <br/>
        Количество точек: <input type='text' onChange={this.handleChangePointsCount} />
        <div>График: {this.state.equation}</div>
        <div>Количество точек: {this.state.pointsCount}</div>
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
