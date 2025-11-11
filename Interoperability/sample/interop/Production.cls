Class sample.interop.Production Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="sample.interop.Production" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="sample.interop.CsvFileService" Category="" ClassName="sample.interop.CsvFileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
   <Setting Target="Adapter" Name="FilePath">/home/irisowner/fileInput/</Setting>
   <Setting Target="Adapter" Name="ArchivePath">/home/irisowner/ProcessedFiles/</Setting>
  </Item>
  <Item Name="sample.interop.ToEmail" Category="" ClassName="sample.interop.ToEmail" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="sample.interop.ToUpdateStock" Category="" ClassName="sample.interop.ToUpdateStock" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="sample.interop.BPWizardRouter" Category="" ClassName="sample.interop.BPWizardRouter" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
