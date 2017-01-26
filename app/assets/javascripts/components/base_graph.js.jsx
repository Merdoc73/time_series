class BaseGraph extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      equation: props.equation,
      pointsCount: props.pointsCount
    };
    this.getGraph = this.getGraph.bind(this);
    google.charts.load('current', {'packages':['annotationchart']});
  };

  componentWillReceiveProps(nextProps) {
    console.log(nextProps);
    this.setState({
      equation: nextProps.equation,
      pointsCount: nextProps.pointsCount
    });
  };


  render() {
    return (
      <div className="no-padding">
        <div>{this.state.equation}</div>
        <button onClick={this.getGraph}>Построить график функции</button>
        <Chart elementId='chart_div' rows={this.state.coords} />
      </div>
    );
  };
  getGraph(e) {
    console.log(this.state);
    self = this;
    $.post('/api/base_graph', {equation: self.state.equation, points_count: self.state.pointsCount}, function(data) {
      self.setState(data);
    }, "json");
    return 'ok';
  }
}
