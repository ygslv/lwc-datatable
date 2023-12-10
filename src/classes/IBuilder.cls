public interface IBuilder {
  void build();
  IBuilder setColumns(List<String> columns);
  IBuilder setData(List<List<String>> data);
}
