class DeviationGraph extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      equation: props.equation,
      pointsCount: props.pointsCount
    };
    this.getGraph = this.getGraph.bind(this);
  };

  componentWillReceiveProps(nextProps) {
    console.log(nextProps);
    if (nextProps.equation == this.state.equation && nextProps.pointsCount == this.state.pointsCount)
      return
    this.setState({
      equation: nextProps.equation,
      pointsCount: nextProps.pointsCount
    });
  };

  render() {
    return (
      <div>
        <button onClick={this.getGraph}>Построить график с аномалией</button>
        {this.state.deviation_equation &&
            <div>Функция: {this.state.deviation_equation}</div>}
        <Chart elementId='deviation_chart_div' rows={[this.state.coords]} />
        {this.state.anomalies} <br/>
        {this.state.all}
      </div>
    );
  };
  getGraph(state, e) {
    self = this;
    $.post('/api/deviation_graph', {equation: self.state.equation, points_count: self.state.pointsCount}, function(data) {
      self.setState(data);
      self.calcSlidingWindow(data.row.join());
    }, "json");
    return 'ok';
  }
  calcSlidingWindow(row) {
    self = this;
    $.post('/api/anomaly_detector', {type: 'sliding_window', row: row}, function(data) {
      self.setState(data);
    }, "json");
    return 'ok';
  }
}
