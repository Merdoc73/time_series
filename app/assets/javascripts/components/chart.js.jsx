class Chart extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      rows: props.rows,
      elementId: props.elementId
    };
  };
  componentWillUpdate(nextProps, nextState) {
    if (nextProps == this.props || nextProps.rows == [] || nextProps.rows[0] == null)
      return
    var options = {
      title: 'My Daily Activities'
    };
    var chart = new google.visualization.LineChart(document.getElementById(nextProps.elementId));
    var data = new google.visualization.DataTable();
    data.addColumn('number', 'x');
    data.addColumn('number', 'y');
    console.log(this.props);
    coords = nextProps.rows[0].map(function(array){
     return [array[0], parseFloat(array[1])];
    });
    data.addRows(coords);
    chart.draw(data, options);
  };
  componentDidUpdate() {
    console.log('updated');
  };
  render() {
    return (
      <div>
        <div id={this.props.elementId}></div>
      </div>
    );
  }
}

