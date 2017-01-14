class DeviationGraph extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      equation: props.equation,
      pointsCount: props.pointsCount
    };
    this.getGraph = this.getGraph.bind(this);
    this.handleChangeManualEquation = this.handleChangeManualEquation.bind(this);
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
        <button onClick={this.getGraph}>Построить график с аномалией</button><br/>
        Функция аномалии: <input type='text' onChange={this.handleChangeManualEquation} />
        {this.state.deviation_equation &&
            <div>Функция: {this.state.deviation_equation}</div>}
        <Chart elementId='deviation_chart_div' rows={[this.state.coords]} />
        {this.state.sliding_window &&
            <div>
              Метод скользящего окна:<br/>
              {this.state.sliding_window.anomalies} <br/>
              {this.state.sliding_window.all}
            </div>
        }
      </div>
    );
  };
  getGraph(state, e) {
    self = this;
    $.post('/api/deviation_graph', {equation: self.state.equation, points_count: self.state.pointsCount, deviation_equation: self.state.manual_equation}, function(data) {
      self.setState(data);
      self.calcSlidingWindow(data.row.join());
    }, "json");
    return 'ok';
  };
  calcSlidingWindow(row) {
    self = this;
    $.post('/api/anomaly_detector', {type: 'sliding_window', row: row}, function(data) {
      self.setState({sliding_window: data});
    }, "json");
    return 'ok';
  };

  handleChangeManualEquation(e) {
    this.setState({manual_equation: e.target.value});
  }
}
