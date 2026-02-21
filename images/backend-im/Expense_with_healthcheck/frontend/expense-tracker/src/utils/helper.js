import moment from "moment"

export const validateEmail = (email) => {
    const regex = /^[^\s@]+@[^\s@]+\.[^/s@]+$/
    return regex.test(email)
}


export const getInitials = (name)=>{
    if(!name) return ""

    const words = name.split(" ")
    let initials = ""

    for(let i=0; i< Math.min(words.length, 2); i++){
        initials +=words[i][0]
    }

    return initials.toUpperCase()
}


export const addThousandsSeparator = (num) =>{
    if (num == null || isNaN(num)) return ""

    const [integerPart, fractionalPart] = num.toString().split(".")
    const formattedInteger = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, ",")

    return fractionalPart
        ?`${formattedInteger}.${fractionalPart}`: formattedInteger
}

export const prepareExpenseBarChartData = (data = []) => {
  const dailyTotals = {}

  const today = moment()
  const thirtyDaysAgo = moment().subtract(30, 'days')

  data.forEach((item) => {
    const itemDate = moment(item.date)

    if (itemDate.isBetween(thirtyDaysAgo, today, undefined, '[]')) {
      const day = itemDate.format('D MMM') // e.g., "15 Jul"
      if (!dailyTotals[day]) {
        dailyTotals[day] = 0
      }
      dailyTotals[day] += item.amount || 0
    }
  })

  // Convert object to sorted array
  return Object.entries(dailyTotals)
    .sort((a, b) => moment(a[0], "D MMM") - moment(b[0], "D MMM"))
    .map(([day, amount]) => ({
      day,
      amount
    }))
}


export const prepareIncomeBarChartData = (data=[])=>{
    const sortedData= [...data].sort((a,b)=> new Date(a.date) - new Date(b.date))

    const chartData= sortedData.map((item)=>({
        month: moment(item?.date).format('Do MMM'),
        amount: item?.amount,
        source: item?.source,
    }))

    return chartData
}


export const prepareExpenseLineChartData = (data = [])=>{
    const sortedData = [...data].sort((a,b)=> new Date(a.date)- new Date(b.date))

    const chartData=sortedData.map((item)=>({
        month: moment(item?.date).format('Do MMM'),
        amount: item?.amount,
        category: item?.category

    }))

    return chartData
}