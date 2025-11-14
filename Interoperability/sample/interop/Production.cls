Class sample.interop.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="sample.interop.Production" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="sample.interop.FromCSV" Category="" ClassName="sample.interop.FromCSV" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageTarget">sample.interop.ProcessTransactionRouter</Setting>
    <Setting Target="Adapter" Name="ArchivePath">/home/irisowner/ProcessedFiles</Setting>
    <Setting Target="Adapter" Name="FilePath">/home/irisowner/fileInput</Setting>
    <Setting Target="Adapter" Name="FileSpec">*.csv</Setting>
  </Item>
  <Item Name="sample.interop.ToUpdateStock" Category="" ClassName="sample.interop.ToUpdateStock" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="sample.interop.ToEmail" Category="" ClassName="sample.interop.ToEmail" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials">Gmail</Setting>
    <Setting Target="Adapter" Name="SMTPPort">465</Setting>
    <Setting Target="Adapter" Name="SMTPServer"></Setting>
    <Setting Target="Adapter" Name="SSLConfig">SSLConfig</Setting>
    <Setting Target="Adapter" Name="From">example@example.com</Setting>
    <Setting Target="Adapter" Name="Recipient">example@example.com</Setting>
  </Item>
  <Item Name="sample.interop.ProcessTransactionRouter" Category="" ClassName="sample.interop.ProcessTransactionRouter" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
