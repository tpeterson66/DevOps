function CreateReportItem($item) {
    # Expecting the following object structure
    # @{
    #     "subscriptionId"= "value"
    #     "subscriptionName" = "value"
    #     "impact" = "value"
    #     "category" = "value"
    #     "recommendation" = "value"
    #     "resourceGroup" = "value"
    #     "resource" = "value"
    # }
    # "Category,Business_Impact,Recommendation,SubscriptionID,SubscriptionName,ResourceGroup,resource"
    Add-Content -Path ./report.csv -Value "$($item.category),$($item.impact),$($item.recommendation),$($item.subscriptionId),$($item.subscriptionName),$($item.resourceGroup),$($item.resource)"
}