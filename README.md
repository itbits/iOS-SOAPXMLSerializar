iOS-SOAPXMLSerializar
=====================

This code will serialise and de serialise SOAP Base XMLs 

Sample Map File:
=====================

<xml-mapping>
    <root-node>Name of root node</root-node>
    <node-mappings>
		<node-mapping
        	node="Node Name In XML"
        	property="(NSString) Property Name "
        	type="string" />
		<node-mapping
        	node="Node Name In XML"
        	property="(NSNumber) Property Name "
        	type="number" />
		<node-mapping
        	node="Node Name In XML"
        	property="(Int) Property Name "
        	type="int" />
		<node-mapping
        	node="Node Name In XML"
        	property="(BOOL) Property Name "
        	type="boolean" />
		<node-mapping
            property="(NSArray)Property Name"
            type="array">
            <type-configuration>
                <property key="type" value="reference" />
                <property key="referenceNode" value="Node Name In XML" />
                <property key="referenceClass" value="Reference Class Name" />
            </type-configuration>
  		</node-mapping>
  		<node-mapping
            property="(Reference)Property Name"
            type="reference">
            <type-configuration>
                <property key="referenceNode" value="Node Name In XML" />
                <property key="referenceClass" value="Reference Class Name" />
            </type-configuration>
   		</node-mapping>
	</node-mappings>
</xml-mapping>

