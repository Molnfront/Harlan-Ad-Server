<!---
	Name:			/reports_campaigns.cfm
	Last Updated:	06/02/05
	History:
--->

<cfparam name="form.campaigns" default="">
<cfparam name="form.style" default="html">

<cfset stats = application.campaignManager.getCampaignStats(form.campaigns)>

<!--- chart options and a bit of checking --->
<cfif structIsEmpty(stats)>
	<cflocation url="reports.cfm" addToken="false">
<cfelseif listLen(structKeyList(stats)) is 1>
	<cfset multiple = false>
<cfelse>
	<cfset multiple = true>
</cfif>
<cfset chartWidth = "650">
<cfset chartHeight = "450">

<cfif form.style is "html">

	<cfmodule template="tags/layout.cfm" title="#application.title# - Campaign Reports">
	
	<cfoutput>
	<h2>Campaign Reports</h2>
	
	<p>
	<h3>General Stats</h3>
	<table class="table table-striped table-bordered table-condensed">
	<tr>
		<td><b>Campaign</b></td><td><b>Impressions / Clicks / CTR</b></td><td><b>First / Last Impression</b></td><td><b>First / Last Click</b></td>
	</tr>
	</cfoutput>

	<cfloop item="c" collection="#stats#">
	
		<cfoutput>
		<tr>
			<td>#stats[c].name#</td>
			<td>#numberFormat(stats[c].totalimpressions)# / #numberFormat(stats[c].totalclicks)# / #numberFormat(stats[c].ctr*100,"0.00")#%</td>
			<td><cfif len(stats[c].firstimpression)>#dateFormat(stats[c].firstimpression,"mm/dd/yy")# #timeFormat(stats[c].firstimpression,"h:mm tt")#<cfelse>None</cfif> / <cfif len(stats[c].lastimpression)>#dateFormat(stats[c].lastimpression,"mm/dd/yy")# #timeFormat(stats[c].lastimpression,"h:mm tt")#<cfelse>None</cfif></td>
			<td><cfif len(stats[c].firstclick)>#dateFormat(stats[c].firstclick,"mm/dd/yy")# #timeFormat(stats[c].firstclick,"h:mm tt")#<cfelse>None</cfif> / <cfif len(stats[c].lastclick)>#dateFormat(stats[c].lastclick,"mm/dd/yy")# #timeFormat(stats[c].lastclick,"h:mm tt")#<cfelse>None</cfif></td>
		</tr>
		</cfoutput>
	</cfloop>

	<cfoutput>
	</table>
	</p>
	</cfoutput>
		
	<cfloop item="c" collection="#stats#">
		<cfoutput>
		<p>
		<h3>Ad Stats: #stats[c].name#</h3>
		<table class="table table-striped table-bordered table-condensed">
		<tr>
			<td><b>Name</b></td><td><b>Impressions / Clicks / CTR</b></td>
		</tr>	
		</cfoutput>
		
		<cfset ads = application.campaignManager.getScheduledAds(c)>

		<cfloop query="ads">
			<cfoutput>
			<tr>
				<td>#adname#</td>
				<cfif structKeyExists(stats[c].addata, adidfk)>
					<cfif stats[c].addata[adidfk].impressions gte 1>
						<cfset ctr = stats[c].addata[adidfk].clicks / stats[c].addata[adidfk].impressions>
					<cfelse>
						<cfset ctr = 0>
					</cfif>		
					<td>#numberFormat(stats[c].addata[adidfk].impressions)# / #numberFormat(stats[c].addata[adidfk].clicks)# / #numberFormat(ctr*100,"0.00")#%</td>
				<cfelse>
					<td>0 / 0 / 0%</td>
				</cfif>
			</tr>
			</cfoutput>
		</cfloop>

		<cfoutput>
		</table>
		</cfoutput>
				
	</cfloop>

	<cfoutput>
	</p>
	<p class="well">
	</cfoutput>
	
	<cfchart show3d=true chartwidth="#chartWidth#" chartheight="#chartHeight#" backgroundColor="##eff7e0" showLegend="#multiple#" title="Impressions Over Time">
		<cfloop item="c" collection="#stats#">
			<cfset impdata = application.utils.toQuery(stats[c].impdata_day,"day")>
			<cfchartseries type="bar" seriesLabel="#stats[c].name#" query="impdata" valueColumn="data" itemColumn="day"/>
		</cfloop>
	</cfchart>
					
	<cfoutput>
	</p>
	
	<p class="well">
	</cfoutput>

	<cfchart show3d=true chartwidth="#chartWidth#" chartheight="#chartHeight#" backgroundColor="##eff7e0" showLegend="#multiple#" title="Clicks Over Time">
		<cfloop item="c" collection="#stats#">
			<cfset cdata = application.utils.toQuery(stats[c].clickdata_day,"day")>
			<cfchartseries type="bar" seriesLabel="#stats[c].name#" query="cdata" valueColumn="data" itemColumn="day" />
		</cfloop>
	</cfchart>
					
	<cfoutput>
	</p>
	
	<p class="well">
	</cfoutput>	

	<cfchart show3d=true chartwidth="#chartWidth#" chartheight="#chartHeight#" backgroundColor="##eff7e0" showLegend="#multiple#" title="Impressions By Hour">
		<cfloop item="c" collection="#stats#">
			<cfset idata = application.utils.toQuery(stats[c].impdata_hour,"hour")>
			<cfchartseries type="bar" seriesLabel="#stats[c].name#" query="idata" valueColumn="data" itemColumn="hour" />
		</cfloop>
	</cfchart>
					
	<cfoutput>
	</p>

	<p class="well">
	</cfoutput>

	<cfchart show3d=true chartwidth="#chartWidth#" chartheight="#chartHeight#" backgroundColor="##eff7e0" showLegend="#multiple#" title="Clicks By Hour">
		<cfloop item="c" collection="#stats#">
			<cfset cdata = application.utils.toQuery(stats[c].clickdata_hour,"hour")>
			<cfchartseries type="bar" seriesLabel="#stats[c].name#" query="cdata" valueColumn="data" itemColumn="hour" />
		</cfloop>
	</cfchart>
					
	<cfoutput>
	</p>
	</cfoutput>
	</cfmodule>

<cfelse>

	<cfsetting showdebugoutput=false>
	<cfcontent TYPE="application/msexcel">
	<cfheader name="content-disposition" value="attachment;filename=campaign_report.xls">  

	<cfoutput>
	<table class="table table-striped table-bordered table-condensed">
	<tr bgcolor="yellow">
		<td><b>Campaign</b></td><td><b>Impressions</b></td><td><b>Clicks</b><td><b>CTR</b></td><td><b>First Impression</b></td><td><b>Last Impression</b></td><td><b>First Click</b></td><td><b>Last Click</b></td>
	</tr>
	</cfoutput>

	<cfloop item="c" collection="#stats#">
	
		<cfoutput>
		<tr>
			<td>#stats[c].name#</td>
			<td>#numberFormat(stats[c].totalimpressions)#</td><td>#numberFormat(stats[c].totalclicks)#</td><td>#numberFormat(stats[c].ctr*100,"0.00")#%</td>
			<td><cfif len(stats[c].firstimpression)>#dateFormat(stats[c].firstimpression,"mm/dd/yy")# #timeFormat(stats[c].firstimpression,"h:mm tt")#<cfelse>None</cfif></td><td><cfif len(stats[c].lastimpression)>#dateFormat(stats[c].lastimpression,"mm/dd/yy")# #timeFormat(stats[c].lastimpression,"h:mm tt")#<cfelse>None</cfif></td>
			<td><cfif len(stats[c].firstclick)>#dateFormat(stats[c].firstclick,"mm/dd/yy")# #timeFormat(stats[c].firstclick,"h:mm tt")#<cfelse>None</cfif></td><td><cfif len(stats[c].lastclick)>#dateFormat(stats[c].lastclick,"mm/dd/yy")# #timeFormat(stats[c].lastclick,"h:mm tt")#<cfelse>None</cfif></td>
		</tr>
		</cfoutput>
	</cfloop>

	<cfoutput>
	</table>
	</cfoutput>

</cfif>