List<int> _orderFilterList = [
  30,
  60,
  90,
  120,
  150,
  180,
  365,
];

int _selectedOrderFilter = 30;

List<int> get orderFilterList => _orderFilterList;
int get selectedOrderFilter => _selectedOrderFilter;

set selectedOrderFilter(int filter) {
  _selectedOrderFilter = filter;
}
