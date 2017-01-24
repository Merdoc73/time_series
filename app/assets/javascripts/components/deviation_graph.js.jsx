class DeviationGraph extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      equation: props.equation,
      pointsCount: props.pointsCount
    };
    this.getGraph = this.getGraph.bind(this);
    this.handleChangeManualEquation = this.handleChangeManualEquation.bind(this);
    this.handleChangeManualEquationLength = this.handleChangeManualEquationLength.bind(this);
    this.handleChangeNoise = this.handleChangeNoise.bind(this);
    this.handleChangeBlowout = this.handleChangeBlowout.bind(this);
      $( document ).ready(function() {
          document.getElementById("defaultOpen").click();
          document.getElementById("defaultOpen").className += " active";
      });
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
        Функция аномалии: <input type='text' onChange={this.handleChangeManualEquation} /><br/>
        Длина функции аномалии: <input type='text' onChange={this.handleChangeManualEquationLength} /><br/>
        Шум: <input type='text' onChange={this.handleChangeNoise} /><br/>
        Количество выбросов: <input type='text' onChange={this.handleChangeBlowout} />
        {this.state.deviation_equation &&
            <div>Функция: {this.state.deviation_equation}</div>}


          <ul className="tab">
              <li><a href="javascript:void(0)" id="defaultOpen" className="tablinks" onClick={(e) => this.openTab(event, 'okno')}>Метод скользящего окна</a></li>
              <li><a href="javascript:void(0)" className="tablinks" onClick={(e) => this.openTab(event, 'fuzzy')}>Анализ лингвистического ВР</a></li>
          </ul>
          <div id="okno" className="tabcontent">
              {this.state.sliding_window &&
              <div>
                  <Chart elementId='deviation_chart_div' rows={[this.state.coords]} isAnomaly={true} anomalies={this.state.sliding_window && this.state.sliding_window.anomalies}/>
                  <table className="table table-bordered table-hover">
                      <tbody>
                      <tr>
                          <th>Элементы окна</th>
                          <th>Тенденция</th>
                          <th>Среднее значение</th>
                          <th>Максимальное по модулю отклонение на отрезке </th>
                          <th>Средняя разница в значениях между соседними точками</th>
                          <th>Дисперсия</th>
                      </tr>
                      {this.state.sliding_window.var_table.map(function(element, index){
                          return (
                              <tr key={index} className={element[6] ? 'danger' : ''}>
                                  <td>{element[0]}</td>
                                  <td>{element[1]}</td>
                                  <td>{element[2]}</td>
                                  <td>{element[3]}</td>
                                  <td>{element[4]}</td>
                                  <td>{element[5]}</td>
                              </tr>
                          );
                      })}
                      </tbody>
                  </table>
              </div>
              }
          </div>

          <div id="fuzzy" className="tabcontent">
              {this.state.fuzzy &&
                  <div>
                      <Chart elementId='deviation_chart_div_fuzzy' rows={[this.state.coords]} isAnomaly={true} anomalies={this.state.fuzzy && this.state.fuzzy.anomalies_indexes.map(function(e) { return (e - 1).toString() + "-" + (e + 1).toString()}).join(';')}/>
                      Поиск аномалий по символам ЛНВР:
                      <table className="table-bordered table-hover">
                          <tbody>
                          <tr>
                              <th>Символы алфавита S(j)</th>
                              <th>Термы нечетких множеств</th>
                              <th>Количетво появления символов в ЛНВР</th>
                              <th>Частотный индекс символа</th>
                              <th>Моменты времени для аномальных символов</th>
                          </tr>
                          {this.state.fuzzy.var_table.map(function(element, index){
                              return (
                                  <tr key={index}>
                                      <td>{element[0]}</td>
                                      <td>{element[1]}</td>
                                      <td>{element[2]}</td>
                                      <td>{element[3]}</td>
                                      <td>{element[4]}</td>
                                  </tr>
                              );
                          })}
                          </tbody>
                      </table>
                      <br/>
                      Поиск аномалий по нечеткой тенденции:
                      <table className="table-bordered table-hover">
                          <tbody>
                          <tr>
                              <th>Символы алфавита S(j)</th>
                              <th>Символы Типов НЭТ</th>
                              <th>Символы Интенсивности НЭТ</th>
                              <th>Количество символов НЭТ</th>
                              <th>Частотный индекс символа</th>
                              <th>Моменты времени для аномальных символов</th>
                          </tr>
                          {this.state.fuzzy.trend_table.map(function(element, index){
                              return (
                                  <tr key={index}>
                                      <td>{element[0]}</td>
                                      <td>{element[1]}</td>
                                      <td>{element[2]}</td>
                                      <td>{element[3]}</td>
                                      <td>{element[4]}</td>
                                      <td>{element[5]}</td>
                                  </tr>
                              );
                          })}
                          </tbody>
                      </table>
                      <br/>
                  </div>
              }
          </div>
      </div>
    );
  };
  openTab(evt, tabName) {
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }

    tablinks = document.getElementsByClassName("tablinks");
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].className = tablinks[i].className.replace(" active", "");
    }

    contentElement = document.getElementById(tabName);
    if (contentElement) {
        contentElement.style.display = "block";
        evt.currentTarget.className += " active";
    }
  };
  getGraph(state, e) {
    self = this;
    $.post('/api/deviation_graph', {equation: self.state.equation, points_count: self.state.pointsCount, deviation_equation: self.state.manual_equation, deviation_length: self.state.manual_equation_length, noise: self.state.noise, blowout: self.state.blowout}, function(data) {
      self.setState(data);
      self.calcSlidingWindow(data.row.join());
      self.calcFuzzyTimeseries(data.row.join())
    }, "json");
    return 'ok';
  };
  calcSlidingWindow(row) {
    self = this;
    $.post('/api/anomaly_detector', {type: 'sliding_window', row: row}, function(data) {
      self.setState({sliding_window: data});
      self.setState({sliding_window: data});
    }, "json");
    return 'ok';
  };
    calcFuzzyTimeseries(row) {
    self = this;
    $.post('/api/anomaly_detector', {type: 'fuzzy', row: row}, function(data) {
      self.setState({fuzzy: data});
      self.setState({fuzzy: data});
    }, "json");
    return 'ok';
  };

  handleChangeManualEquation(e) {
    this.setState({manual_equation: e.target.value});
  }

    handleChangeManualEquationLength(e) {
        this.setState({manual_equation_length: e.target.value});
    }

    handleChangeNoise(e) {
        this.setState({noise: e.target.value});
    }

    handleChangeBlowout(e) {
        this.setState({blowout: e.target.value});
    }
}
